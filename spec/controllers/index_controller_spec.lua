require 'spec.spec_helper'

describe("PagesController", function()

    describe("#root", function()
        it("responds with a welcome message", function()
            local response = hit({
                method = 'GET',
                path = "/"
            })

            assert.are.same(200, response.status)
            assert.are.same({ message = "Hello world from Va!" }, response.body)
        end)
    end)
end)
