require "test_helper"

class CardComponentTest < ViewComponent::TestCase
  test "renders default card with shadow" do
    render_inline(CardComponent.new) do |card|
      card.with_body { "Content" }
    end
    assert_selector("div.shadow", text: "Content")
  end

  test "renders bordered variant" do
    render_inline(CardComponent.new(variant: :bordered)) do |card|
      card.with_body { "Content" }
    end
    assert_selector("div.border")
  end

  test "renders title slot" do
    render_inline(CardComponent.new) do |card|
      card.with_title { "Title" }
      card.with_body { "Body" }
    end
    assert_selector("div.font-semibold", text: "Title")
  end

  test "renders footer slot" do
    render_inline(CardComponent.new) do |card|
      card.with_body { "Body" }
      card.with_footer { "Footer" }
    end
    assert_selector("div.border-t", text: "Footer")
  end

  test "renders neo default card" do
    render_inline(CardComponent.new(style: :neo)) do |card|
      card.with_title { "Title" }
      card.with_body { "Body" }
    end
    assert_selector("div.border-2.border-black")
    assert_selector("div[class*='shadow-']")
    assert_no_selector("div.rounded-lg")
  end

  test "renders neo card with uppercase bold title" do
    render_inline(CardComponent.new(style: :neo)) do |card|
      card.with_title { "Title" }
    end
    assert_selector("div.font-bold.uppercase", text: "Title")
  end

  test "renders neo card with thick footer border" do
    render_inline(CardComponent.new(style: :neo)) do |card|
      card.with_body { "Body" }
      card.with_footer { "Footer" }
    end
    assert_selector("div.border-t-2.border-black", text: "Footer")
  end
end
