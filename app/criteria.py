from fasthtml import HTML, HTMLPage

# List of 118 criteria (example: "Criterion 1", "Criterion 2", ..., "Criterion 118")
criteria = [f"Criterion {i+1}" for i in range(118)]

# Create the HTML page
page = HTMLPage(title="Criteria Weighting App")

# Add a heading
page.add(HTML.h1("Criteria Weighting App", style="text-align: center; margin: 20px 0;"))

# Create a form for the criteria
form = HTML.form(action="/submit", method="post")

# Add a table to organize the criteria, weights, and types
table = HTML.table(style="width: 100%; border-collapse: collapse;")
table.add(HTML.tr(
    HTML.th("Criterion", style="padding: 10px; border: 1px solid #ddd;"),
    HTML.th("Weight", style="padding: 10px; border: 1px solid #ddd;"),
    HTML.th("Positive/Negative", style="padding: 10px; border: 1px solid #ddd;")
))

# Add rows for each criterion
for i, criterion in enumerate(criteria):
    row = HTML.tr(
        HTML.td(criterion, style="padding: 10px; border: 1px solid #ddd;"),
        HTML.td(
            HTML.input(type="number", name=f"weight-{i}", value="1.0", min="0", step="0.1", style="width: 100%; padding: 5px;"),
            style="padding: 10px; border: 1px solid #ddd;"
        ),
        HTML.td(
            HTML.select(
                HTML.option("Positive", value="positive", selected=True),
                HTML.option("Negative", value="negative"),
                name=f"type-{i}",
                style="width: 100%; padding: 5px;"
            ),
            style="padding: 10px; border: 1px solid #ddd;"
        )
    )
    table.add(row)

# Add the table to the form
form.add(table)

# Add a submit button
form.add(HTML.button("Submit", type="submit", style="margin: 20px 0; padding: 10px 20px; background-color: #007bff; color: white; border: none; cursor: pointer;"))

# Add the form to the page
page.add(form)

# Add a placeholder for the output message
output_div = HTML.div(id="output-message", style="text-align: center; margin: 20px 0;")
page.add(output_div)

# Save the page to an HTML file
with open("criteria_app.html", "w") as f:
    f.write(str(page))

print("App created successfully! Open 'criteria_app.html' in your browser.")