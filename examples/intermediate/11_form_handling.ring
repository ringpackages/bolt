# Form Handling & Validation with MiniJinja Templates
# Run: ring 11_form_handling.ring
# Open: http://localhost:3000
#
# This example demonstrates:
#   - renderFile() for form pages with re-rendering on validation errors
#   - Server-side form validation with user-friendly error messages
#   - Preserving form values on error so users don't lose their input
#   - JSON API endpoint for programmatic form submission
#
# Template files are in the ./templates/ directory:
#   form_contact.html - Contact form with inline error display
#   form_success.html - Confirmation page with submitted data

load "bolt.ring"

new Bolt() {
    port = 3000

    @get("/", func {
        $bolt.renderFile("./templates/form_contact.html", [
            :name = "",
            :email = "",
            :age = "",
            :country = "USA",
            :message = "",
            :errors = []
        ])
    })

    @post("/submit", func {
        cName = $bolt.formField("name")
        cEmail = $bolt.formField("email")
        cAge = $bolt.formField("age")
        cCountry = $bolt.formField("country")
        cMessage = $bolt.formField("message")

        aErrors = []

        if cName = "" or len(cName) < 2
            add(aErrors, "Name must be at least 2 characters")
        ok

        if cEmail = "" or not substr(cEmail, "@")
            add(aErrors, "Valid email required")
        ok

        if cAge != "" and (0 + cAge) < 1
            add(aErrors, "Age must be positive")
        ok

        if len(aErrors) > 0
            $bolt.renderFile("./templates/form_contact.html", [
                :name = cName,
                :email = cEmail,
                :age = cAge,
                :country = cCountry,
                :message = cMessage,
                :errors = aErrors
            ])
            return
        ok

        $bolt.renderFile("./templates/form_success.html", [
            :name = cName,
            :email = cEmail,
            :age = cAge,
            :country = cCountry,
            :message = cMessage
        ])

        ? "--- Form Submitted ---"
        ? "Name:    " + cName
        ? "Email:   " + cEmail
        ? "Age:     " + cAge
        ? "Country: " + cCountry
        ? "Message: " + cMessage
    })

    # curl -X POST http://localhost:3000/api/register -H "Content-Type: application/json" -d '{"username":"alice","email":"alice@test.com","age":25}'
    @post("/api/register", func {
        cBody = $bolt.body()
        ? "Registration data: " + cBody

        $bolt.json([
            :success = true,
            :message = "User registered",
            :data = cBody
        ])
    })
}
