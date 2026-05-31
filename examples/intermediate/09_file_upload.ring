# File Upload - Multipart Form Data with MiniJinja Templates
# Run: ring 09_file_upload.ring
# Open: http://localhost:3000
#
# This example demonstrates:
#   - renderFile() to load templates from .html files
#   - File upload with multipart/form-data
#   - JSON API endpoint for file upload
#
# Template files are in the ./templates/ directory:
#   upload_form.html    - Upload form page
#   upload_success.html - Success page with file details

load "bolt.ring"
load "stdlibcore.ring"

new Bolt() {
    port = 3000

    @get("/", func {
        $bolt.renderFile("./templates/upload_form.html", [])
    })

    @post("/upload", func {
        cUsername = $bolt.formField("username")
        cDescription = $bolt.formField("description")

        ? "Upload from: " + cUsername
        ? "Description: " + cDescription
        ? "Files count: " + $bolt.filesCount()

        if $bolt.filesCount() > 0
            f = $bolt.file(1)
            cFilename = f[:name]
            cSize = f[:size]
            cType = f[:type]

            # Sanitize filename — strip path separators and null bytes
            while substr(cFilename, "/")
                nPos = substr(cFilename, "/")
                cFilename = substr(cFilename, nPos + 1)
            end
            while substr(cFilename, "\\")
                nPos = substr(cFilename, "\\")
                cFilename = substr(cFilename, nPos + 1)
            end
            cFilename = substr(cFilename, 1, 255)

            aAllowed = [".txt", ".png", ".jpg", ".jpeg", ".gif", ".pdf", ".csv", ".zip"]
            bAllowed = false
            nMax = len(aAllowed)
            for i = 1 to nMax
                nExtLen = len(aAllowed[i])
                if lower(right(cFilename, nExtLen)) = aAllowed[i]
                    bAllowed = true
                    exit
                ok
            next
            if !bAllowed
                $bolt.badRequest("File type not allowed. Allowed: txt, png, jpg, gif, pdf, csv, zip")
                return
            ok

            ? "Filename: " + cFilename
            ? "Size: " + cSize + " bytes"
            ? "Type: " + cType

            if !fexists("./uploads")
                makeDir("uploads")
            ok

            $bolt.fileSave(1, "./uploads/" + cFilename)

            $bolt.renderFile("./templates/upload_success.html", [
                :username = cUsername,
                :description = cDescription,
                :filename = cFilename,
                :size = cSize
            ])
        else
            $bolt.send("No file uploaded!")
        ok
    })

    # curl -X POST http://localhost:3000/api/upload -F "file=@test.txt" -F "description=My file"
    @post("/api/upload", func {
        cDesc = $bolt.formField("description")

        if $bolt.filesCount() > 0
            f = $bolt.file(1)
            cFilename = f[:name]
            cSize = f[:size]

            while substr(cFilename, "/")
                nPos = substr(cFilename, "/")
                cFilename = substr(cFilename, nPos + 1)
            end
            while substr(cFilename, "\\")
                nPos = substr(cFilename, "\\")
                cFilename = substr(cFilename, nPos + 1)
            end
            cFilename = substr(cFilename, 1, 255)

            aAllowed = [".txt", ".png", ".jpg", ".jpeg", ".gif", ".pdf", ".csv", ".zip"]
            bAllowed = false
            nMax = len(aAllowed)
            for i = 1 to nMax
                nExtLen = len(aAllowed[i])
                if lower(right(cFilename, nExtLen)) = aAllowed[i]
                    bAllowed = true
                    exit
                ok
            next
            if !bAllowed
                $bolt.badRequest("File type not allowed. Allowed: txt, png, jpg, jpeg, gif, pdf, csv, zip")
                return
            ok

            # Get file by form field name instead of index
            f2 = $bolt.fileByField("file")
            if f2 != NULL
                ? "File by field 'file': " + f2[:name]
            ok

            if !fexists("./uploads")
                makeDir("uploads")
            ok

            $bolt.fileSave(1, "./uploads/" + cFilename)

            $bolt.json([
                :success = true,
                :filename = cFilename,
                :size = cSize,
                :description = cDesc
            ])
        else
            $bolt.jsonWithStatus(400, [
                :success = false,
                :error = "No file provided"
            ])
        ok
    })
}
