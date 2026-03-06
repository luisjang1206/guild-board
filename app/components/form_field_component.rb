# frozen_string_literal: true

class FormFieldComponent < ApplicationComponent
  INPUT_CLASSES = "block w-full rounded-md border-0 py-1.5 text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 placeholder:text-gray-400 focus:ring-2 focus:ring-inset focus:ring-indigo-600 sm:text-sm sm:leading-6"
  INPUT_ERROR_CLASSES = "block w-full rounded-md border-0 py-1.5 text-gray-900 shadow-sm ring-1 ring-inset ring-red-500 placeholder:text-gray-400 focus:ring-2 focus:ring-inset focus:ring-red-600 sm:text-sm sm:leading-6"
  LABEL_CLASSES = "block text-sm font-medium leading-6 text-gray-900"
  ERROR_CLASSES = "mt-1 text-sm text-red-600"

  NEO_INPUT_CLASSES = "block w-full border-2 border-black py-1.5 text-black shadow-[3px_3px_0px_#000000] placeholder:text-gray-500 focus:-translate-x-px focus:-translate-y-px focus:shadow-[5px_5px_0px_#000000] focus:outline-none sm:text-sm"
  NEO_INPUT_ERROR_CLASSES = "block w-full border-2 border-red-600 py-1.5 text-black shadow-[3px_3px_0px_#FF0000] placeholder:text-gray-500 focus:-translate-x-px focus:-translate-y-px focus:shadow-[5px_5px_0px_#FF0000] focus:outline-none sm:text-sm"
  NEO_LABEL_CLASSES = "block text-sm font-bold uppercase leading-6 text-black"
  NEO_ERROR_CLASSES = "mt-1 text-sm font-bold text-red-600"

  def initialize(form:, field_name:, type: :text, label: nil, error_messages: nil, required: false, options: nil, style: :modern, **input_options)
    @form = form
    @field_name = field_name
    @type = type
    @label = label
    @error_messages = error_messages
    @required = required
    @options = options
    @style = style
    @input_options = input_options
  end

  private

  def has_errors?
    @error_messages.present?
  end

  def label_classes
    neo? ? NEO_LABEL_CLASSES : LABEL_CLASSES
  end

  def error_classes
    neo? ? NEO_ERROR_CLASSES : ERROR_CLASSES
  end

  def input_css_classes
    if neo?
      has_errors? ? NEO_INPUT_ERROR_CLASSES : NEO_INPUT_CLASSES
    else
      has_errors? ? INPUT_ERROR_CLASSES : INPUT_CLASSES
    end
  end
end
