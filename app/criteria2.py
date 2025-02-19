from fasthtml import HTMLPage

# List of 118 criteria (example: "Criterion 1", "Criterion 2", ..., "Criterion 118")
criteria = [f"Criterion {i+1}" for i in range(118)]

# Create the HTML page
page = HTMLPage(title="Criteria Weighting App")

# Add a heading
page.add(f"<h1 style='text-align: center; margin: 20px 0;'>Criteria Weighting App</h1>")

# Create a form for the criteria
form = "<form action='/submit' method='post'>"

# Add a table to organize the criteria, weights, and types
table = "<table style='width: 100%; border-collapse: collapse;'>"
table += "<tr>"
table += "<th style='padding: 10px; border: 1px solid #ddd;'>Criterion</th>"
table += "<th style='padding: 10px; border: 1px solid #ddd;'>Weight</th>"
table += "<th style='padding: 10px; border: 1px solid #ddd;'>Positive/Negative</th>"
table += "</tr>"

# Add rows for each criterion
for i, criterion in enumerate(criteria):
    table += "<tr>"
    table += f"<td style='padding: 10px; border: 1px solid #ddd;'>{criterion}</td>"
    table += f"<td style='padding: 10px; border: 1px solid #ddd;'><input type='number' name='weight-{i}' value='1.0' min='0' step='0.1' style='width: 100%; padding: 5px;'></td>"
    table += f"<td style='padding: 10px; border: 1px solid #ddd;'><select name='type-{i}' style='width: 100%; padding: 5px;'><option value='positive' selected>Positive</option><option value='negative'>Negative</option></select></td>"
    table += "</tr>"

table += "</table>"
form += table

# Add a submit button
form += "<button type='submit' style='margin: 20px 0; padding: 10px 20px; background-color: #007bff; color: white; border: none; cursor: pointer;'>Submit</button>"
form += "</form>"

# Add the form to the page
page.add(form)

# Add a placeholder for the output message
page.add("<div id='output-message' style='text-align: center; margin: 20px 0;'></div>")

# Save the page to an HTML file
with open("criteria_app.html", "w") as f:
    f.write(str(page))

print("App created successfully! Open 'criteria_app.html' in your browser.")