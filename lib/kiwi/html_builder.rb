class Kiwi::HTMLBuilder

  def html data
    case data
    when Array
      from_collection(data)
    when Hash
      from_hash(data)
    else
      data.to_s
    end
  end


  def from_collection data
    tag("ol") do |t|
      data.each do |item|
        t << ( tag("li"){|st| st << html(item)} )
      end
    end
  end


  def from_hash data
    if data[:_class]
      return from_link(data) if
        data[:_class].index(Kiwi::Resource::Link.to_s)

      return from_attribute(data) if
        data[:_class].index(Kiwi::Resource::Attribute.to_s)
    end

    attrib = {}
    if data[:_class]
      attrib['class'] = data[:_class].map{|cl| css_name(cl) }.join(" ")

      klass = Kiwi.find_const(data[:_class])
      attrib['id'] = css_name(data[klass.identifier.to_s]) if
        klass && data[klass.identifier.to_s]
    end

    tag("ul", attrib) do |t|
      data.each do |k, v|
        t << ( tag("li", 'class' => k){|st| st << html(v)} )
      end
    end
  end


  def from_link data
    if data[:method].downcase != 'get' || data[:params]
      form_id = gen_form_id
      opts = {
        'method' => data[:method],
        'action' => data[:href],
        'id'     => form_id
      }

      tag("form", opts) do |t|
        t << ( tag('h3'){|st| st << data[:label].to_s} )
        t << ( data[:params].map{|pm| from_attribute(pm, form_id) }.join ) if data[:params]
        t << tag('input', 'type' => 'reset', 'class' => 'reset')
        t << tag('input', 'type' => 'submit', 'class' => 'submit')
      end

    else
      opts = {'rel' => data[:rel], 'href' => data[:href]}
      tag("a", opts){|t| t << (data[:label] || data[:href]) }
    end
  end


  def from_attribute data, parent_id, parent=nil
    name = parent ? "#{parent}[#{data[:name]}]" : data[:name]
    id   = "#{parent_id}-#{data[:name]}"
    opts = {'name' => name, 'id' => id}

    elmt =
      if data[:display] == 'hidden'
        input_tag(data, opts)
      elsif data[:display] == 'textarea'
        textarea_tag(data, opts)
      elsif data[:values]
        select_tag(data, opts)
      else
        input_tag(data, opts)
      end

    if data[:label]
      label = tag('label', 'for' => id){|t| t << data[:label].to_s}
      elmt = "#{label}#{elmt}"
    end

    if data[:attributes]
      elmt << (data[:attributes].map{|pm| from_attribute(pm, id, name) }.join)
    end

    elmt
  end


  def select_tag data, opts={}
    opts[:multiple] = true if data[:collection]

    tag('select', opts) do |t|
      data[:values].each do |item|
        opts = {'value' => item[:value]}
        opts['selected'] = true if data[:value] == item[:value] ||
                                   data[:default] == item[:value]

        t << (tag('option', opts){|st| st << (item[:label] || item[:value])})
      end
    end
  end


  def textarea_tag data, opts={}
    tag('textarea', opts){|t| t << ( data[:value] || data[:default] ).to_s }
  end


  def input_tag data, opts={}
    opts['type']  = data[:display]
    opts['value'] = (data[:value] || data[:default])

    tag('input', opts)
  end


  def tag name, attr=nil
    inner = ""
    yield inner if block_given?

    html_attr = ""
    if attr
      attr.each{|k,v| html_attr << " #{k}=#{css_esc(v).inspect}"}
    end

    if inner.empty?
      "<#{name}#{html_attr} />\n"
    else
      "<#{name}#{html_attr}>#{inner}</#{name}>\n"
    end
  end


  def css_name name
    name.gsub(/::/, '-').
      gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
      gsub(/([a-z\d])([A-Z])/,'\1_\2').
      downcase
  end


  def css_esc val
    val.to_s.gsub(/[^\\]"/, '\1\\"')
  end


  def gen_form_id
    @form_id ||= 0
    @form_id += 1
    "form#{@form_id}"
  end
end
