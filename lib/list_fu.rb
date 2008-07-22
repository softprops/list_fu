module Soft
  module Props
    module ListFu
       module Helpers
        return if ActionView::Base.included_modules.include? Soft::Props::ListFu::Helpers
        
        # Renders an html list of records.
        # args can be one or two hashes of options,
        # the first for the top-level list element and 
        # the second for each list item element.
        #
        # For ordered list pass :ordered=>true
        # in the first hash.
        #
        # If no block is passed then the renderer
        # assumes there is a parial named after the
        # classname of the first item in the collection.
        # For a custom parial please add :partial=>"yourPartialName"
        # in the second hash.
        def list_of(items=[], *args, &block)
          renderer = ListRenderer.new(items,self,*args,&block)
          unless block_given? 
            renderer.to_html
          end
        end

        # Renders an html list given an collection of records
        # Handles yielding items to block if block is given. By default if no block 
        # is passed this class assumes a partial named after the model 
        # exists and renders that passing the record as the the object
        # to the partial.
        class ListRenderer

          def initialize(items,template,*args,&block)
            @items = items || []
            @template = template
            @html=''
            @ul_options = args.first.is_a?(Hash) ? args.shift : {}
            @ul_options[:id] = "#{@items.first.class.to_s.downcase}_list" unless @ul_options.has_key?(:id) || @items.empty?
            @li_options = args.first.is_a?(Hash) ? args.shift : {}
            render(*args,&block)
          end

          def to_html
             @html
          end

          def method_missing(*args, &block)
            @template.send(*args, &block)
          end

          protected
 
          def list(&block)
            list_tags = list_tags_for(@ul_options) 
            concat("#{list_tags[0]}\n", block.binding)
            @items.each do |item|
              li_atts_for(item)
              concat("  <li#{tag_options(@li_options)}>\n   ", block.binding)
               yield(item)
              concat("\n  </li>\n", block.binding)
            end
            concat("#{list_tags[1]}\n", block.binding)
          end

          def list_without_block
            list_tags =  list_tags_for(@ul_options) 
            @html<<"#{list_tags[0]}\n"
            @items.each do |item|
              li_atts_for(item)
              @html<<"  <li#{tag_options(@li_options)}>\n    "
              @html<< @template.render(:partial=>partial_name, :object=> item)
              @html<<"\n  </li>\n"
            end
            @html<<"#{list_tags[1]}"
          end

          private
          
          def render(&block)
            if block_given?
              list(&block)
            else
              list_without_block 
            end
          end

          def li_atts_for(item)
            @li_options[:id] = dom_id(item)
            @li_options[:class] = dom_class(item) unless @li_options.has_key?(:class)
          end
          
          def partial_name
            @partial_name ||= @li_options.has_key?(:partial) ? @li_options.delete(:partial) : (@items.empty? ? "" : @items.first.class.to_s.downcase)
          end

          def list_tags_for(options)
            ordered = options.has_key?(:ordered) ? options.delete(:ordered) : false
            tags = ordered ?  ["<ol#{tag_options(options)}>", "</ol>"] : ["<ul#{tag_options(options)}>", "</ul>"]
          end

          def tag_options(options)
            @template.send :tag_options, options
          end
          
          def dom_id(model)
            @template.send :dom_id, model
          end

        end
      end
    end
  end
end