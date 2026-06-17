module RunsHelper
  def sort_link(column, label)
    active     = @sort == column
    descending = active && @direction == "desc"
    direction  = descending ? "asc" : "desc"
    indicator  = active ? (descending ? "▼" : "▲") : "↕"

    link_to request.query_parameters.merge(sort: column, direction: direction),
      class: class_names("sort-link", active: active),
      data: { turbo_frame: "runs", turbo_action: "advance" } do
      safe_join([ label, content_tag(:span, indicator, class: "sort-link__icon") ], " ")
    end
  end
end
