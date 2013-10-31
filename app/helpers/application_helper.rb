module ApplicationHelper
  def controller?(*controller)
    controller.include?(params[:controller])
  end

  def action?(*action)
    action.include?(params[:action])
  end

  def inside_layout(parent_layout)
    view_flow.set :layout, capture { yield }
    render template: "layouts/#{parent_layout}"
  end
end
