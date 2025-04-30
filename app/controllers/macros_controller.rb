class MacrosController < ApplicationController
  def display_form
    render({:template => "macro_templates/new_form"})
  end

  def do_magic
    @the_description = params.fetch("description_param")
    @the_image = params.fetch("image_param")
    @the_image_converted = DataURI.convert(@the_image)

    c = OpenAI::Chat.new
    c.model = "gpt-4.1-nano"
    c.system("You are an expert nutritionist. Your job is to estimate how many grams of carbohydrates, grams of protein, grams of fat, and total calories are in a meal. You should also add a breakdown of how you arrived at these figures, and any other notes you have. The user will provide either a photo, a description, or both.")

    c.schema = '{
      "name": "nutrition_info",
      "schema": {
        "type": "object",
        "properties": {
          "carbohydrates": {
            "type": "number",
            "description": "Amount of carbohydrates in grams."
          },
          "protein": {
            "type": "number",
            "description": "Amount of protein in grams."
          },
          "fat": {
            "type": "number",
            "description": "Amount of fat in grams."
          },
          "total_calories": {
            "type": "number",
            "description": "Total calories in kcal."
          },
          "notes": {
            "type": "string",
            "description": "A breakdown of how you arrived at the values, and additional notes."
          }
        },
        "required": [
          "carbohydrates",
          "protein",
          "fat",
          "total_calories",
          "notes"
        ],
        "additionalProperties": false
      },
      "strict": true
    }'

    c.user(@the_description, image: @the_image)
    @result = c.assistant!
    
    @g_carbs = @result.fetch("carbohydrates")
    @g_protein = @result.fetch("protein")
    @g_fat = @result.fetch("fat")
    @kcal = @result.fetch("total_calories")
    @notes = @result.fetch("notes")

    render({:template => "macro_templates/results"})
  end

end
