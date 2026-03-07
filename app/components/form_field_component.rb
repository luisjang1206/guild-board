# frozen_string_literal: true

class FormFieldComponent < ApplicationComponent
  STYLES = {
    modern: {
      input: "block w-full rounded-md border-0 py-1.5 text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 placeholder:text-gray-400 focus:ring-2 focus:ring-inset focus:ring-indigo-600 sm:text-sm sm:leading-6",
      input_error: "block w-full rounded-md border-0 py-1.5 text-gray-900 shadow-sm ring-1 ring-inset ring-red-500 placeholder:text-gray-400 focus:ring-2 focus:ring-inset focus:ring-red-600 sm:text-sm sm:leading-6",
      label: "block text-sm font-medium leading-6 text-gray-900",
      error: "mt-1 text-sm text-red-600"
    },
    neo: {
      input: "block w-full border-2 border-black py-1.5 text-black shadow-[3px_3px_0px_var(--color-black)] placeholder:text-gray-500 focus:-translate-x-px focus:-translate-y-px focus:shadow-[5px_5px_0px_var(--color-black)] focus:outline-none sm:text-sm",
      input_error: "block w-full border-2 border-red-600 py-1.5 text-black shadow-[3px_3px_0px_#FF0000] placeholder:text-gray-500 focus:-translate-x-px focus:-translate-y-px focus:shadow-[5px_5px_0px_#FF0000] focus:outline-none sm:text-sm",
      label: "block text-sm font-bold uppercase leading-6 text-black",
      error: "mt-1 text-sm font-bold text-red-600"
    }
  }.freeze

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
    style_for(:label)
  end

  def error_classes
    style_for(:error)
  end

  def input_css_classes
    has_errors? ? style_for(:input_error) : style_for(:input)
  end
end
