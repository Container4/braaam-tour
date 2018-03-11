module TourNeedComponent
  extend ComponentHelper
  property :value, required: true
  property :type, required: true

  def text
    type_content[:text_value]
  end

  def icon
    type_content[:icon_value]
  end

  private

  def type_content
    case @type
    when "independent"
      text_value = t ".true_independent" if @value.eql?(true)
      text_value = t ".false_independent" if @value.eql?(false)

      {
        icon_value: content_tag(:i, "", class: "fas fa-cogs fa-lg"),
        text_value: text_value
      }
    when "catering"
      text_value = t ".true_catering" if @value.eql?(true)
      text_value = t ".false_catering" if @value.eql?(false)

      {
        icon_value: content_tag(:i, "", class: "fas fa-utensils fa-lg"),
        text_value: text_value
      }
    when "housing"
      text_value = t ".true_housing" if @value.eql?(true)
      text_value = t ".false_housing" if @value.eql?(false)

      {
        icon_value: content_tag(:i, "", class: "fas fa-bed fa-lg"),
        text_value: text_value
      }
    when "transport"
      text_value = t ".true_transport" if @value.eql?(true)
      text_value = t ".false_transport" if @value.eql?(false)

      {
        icon_value: content_tag(:i, "", class: "fas fa-plane fa-lg"),
        text_value: text_value
      }
    end
  end
end