import dash
from dash import dcc, html, Input, Output, State
import dash_bootstrap_components as dbc

# Initialize the Dash app
app = dash.Dash(__name__, external_stylesheets=[dbc.themes.BOOTSTRAP])

# List of 118 criteria (example: "Criterion 1", "Criterion 2", ..., "Criterion 118")
criteria = [f"Criterion {i+1}" for i in range(118)]

# Layout of the app
app.layout = dbc.Container([
    html.H1("Criteria Weighting App", className="text-center my-4"),
    html.Div([
        dbc.Row([
            dbc.Col(html.H4("Criterion"), width=6),
            dbc.Col(html.H4("Weight"), width=3),
            dbc.Col(html.H4("Positive/Negative"), width=3),
        ], className="mb-3"),
        *[
            dbc.Row([
                dbc.Col(criterion, width=6),
                dbc.Col(
                    dcc.Input(
                        id=f"weight-{i}",
                        type="number",
                        placeholder="Enter weight",
                        min=0,
                        step=0.1,
                        value=1.0,  # Default weight
                        className="form-control"
                    ),
                    width=3
                ),
                dbc.Col(
                    dcc.Dropdown(
                        id=f"type-{i}",
                        options=[
                            {"label": "Positive", "value": "positive"},
                            {"label": "Negative", "value": "negative"}
                        ],
                        value="positive",  # Default type
                        clearable=False,
                        className="form-control"
                    ),
                    width=3
                ),
            ], className="mb-3")
            for i, criterion in enumerate(criteria)
        ],
        dbc.Row([
            dbc.Col(
                dbc.Button("Submit", id="submit-button", color="primary", className="w-100"),
                width=12
            )
        ], className="my-4"),
        html.Div(id="output-message", className="text-center")
    ])
], fluid=True)

# Callback to handle form submission
@app.callback(
    Output("output-message", "children"),
    Input("submit-button", "n_clicks"),
    [State(f"weight-{i}", "value") for i in range(len(criteria))],
    [State(f"type-{i}", "value") for i in range(len(criteria))]
)
def submit_form(n_clicks, *args):
    if n_clicks is None:
        return ""

    # Split weights and types from args
    weights = args[:len(criteria)]
    types = args[len(criteria):]

    # Validate inputs
    if any(w is None or w < 0 for w in weights):
        return dbc.Alert("Please enter valid weights for all criteria.", color="danger")

    # Prepare results
    results = []
    for i, (weight, type_) in enumerate(zip(weights, types)):
        results.append(f"{criteria[i]}: Weight = {weight}, Type = {type_}")

    return dbc.Alert([html.P("Submitted Data:"), html.Ul([html.Li(result) for result in results])], color="success")

# Run the app
if __name__ == "__main__":
    app.run_server(debug=True)
