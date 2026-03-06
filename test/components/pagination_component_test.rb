require "test_helper"

class PaginationComponentTest < ViewComponent::TestCase
  test "renders pagination when multiple pages" do
    mock_request = Struct.new(:params, :base_url, :path, :query_string)
                         .new({}, "http://test.com", "/test", "")
    pagy = Pagy::Offset.new(count: 100, page: 1, limit: 10, request: mock_request)
    render_inline(PaginationComponent.new(pagy: pagy))
    assert_selector("nav[aria-label='Pagination']")
  end

  test "does not render when single page" do
    pagy = Pagy::Offset.new(count: 5, page: 1, limit: 10)
    render_inline(PaginationComponent.new(pagy: pagy))
    assert_no_selector("nav")
  end
end
