from shiny import App, ui, render, reactive
import pandas as pd

# List of 118 criteria (example: "Criterion 1", "Criterion 2", ..., "Criterion 118")
criteria = [f"Criterion {i+1}" for i in range(118)]

# Define the UI
app_ui = ui.page_fluid(
    ui.h1("Criteria Weighting App", class_="text-center my-4"),
    ui.layout_sidebar(
        sidebar=ui.sidebar(
            *[
                ui.div(
                    ui.h5(criterion),
                    ui.input_numeric(f"weight_{i}", "Weight", value=1.0, min=0, step=0.1),
                    ui.input_select(f"type_{i}", "Positive/Negative", choices=["Positive", "Negative"], selected="Positive"),
                    class_="mb-3"
                )
                for i, criterion in enumerate(criteria)
            ],
            ui.input_action_button("submit", "Submit", class_="btn-primary w-100")
        ),
        main=ui.panel_main(
            ui.output_text("output_message")
        )
    )
)

# Define the server logic
def server(input, output, session):
    @reactive.Calc
    def get_results():
        weights = [input[f"weight-{i}"]() for i in range(len(criteria))]
        types = [input[f"type-{i}"]() for i in range(len(criteria))]
        return pd.DataFrame({
            "Criterion": criteria,
            "Weight": weights,
            "Type": types
        })

    @output
    @render.text
    @reactive.event(input.submit)
    def output_message():
        results = get_results()
        return results.to_string(index=False)

# Create the Shiny app