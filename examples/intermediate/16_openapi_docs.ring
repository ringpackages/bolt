# OpenAPI Documentation & Homepage
# Run: ring 16_openapi_docs.ring

load "bolt.ring"

new Bolt() {
    port = 3000

    setDocsInfo("Pet Store API", "1.0.0", "A simple pet store API for demonstration")
    enableDocs()
    homepage()

    @get("/pets", func {
        $bolt.json([
            :pets = [[:id = 1, :name = "Fluffy", :type = "cat"], [:id = 2, :name = "Rex", :type = "dog"]]
        ])
    })
    describe("List all pets")
    tag("Pets")

    @get("/pets/:id", func {
        $bolt.json([:id = $bolt.param("id"), :name = "Pet " + $bolt.param("id")])
    })
    where("id", "[0-9]+")
    describe("Get pet by ID")
    tag("Pets")

    @post("/pets", func {
        data = $bolt.jsonBody()
        $bolt.jsonWithStatus(201, [:created = true, :pet = data])
    })
    describe("Create a new pet")
    tag("Pets")

    @delete("/pets/:id", func {
        $bolt.sendStatus(204)
    })
    where("id", "[0-9]+")
    describe("Delete a pet")
    tag("Pets")

    @get("/owners", func {
        $bolt.json([:owners = []])
    })
    describe("List all owners")
    tag("Owners")

    @get("/health", func {
        $bolt.json($bolt.healthCheck())
    })

    # Custom OpenAPI spec (uncomment to use)
    # cSpec = $bolt.jsonEncode([
    #     :openapi = "3.1.0",
    #     :info = [:title = "Custom Spec", :version = "2.0.0"],
    #     :paths = [:];
    #     ])
    # setOpenApiSpec(cSpec)
}
