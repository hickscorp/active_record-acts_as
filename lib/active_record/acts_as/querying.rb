module ActiveRecord
  module QueryMethods
    def where_with_acts_as (opts = :chain, *rest)
      if acting_as? && opts.is_a?( Hash )
        opts, acts_as_opts  = opts.stringify_keys.partition{ |k, v| attribute_method? k }
        opts, acts_as_opts  = Hash[ opts ], Hash[ acts_as_opts ]
        unless acts_as_opts.empty?
          acts_infos.each do |assoc, infos|
            opts[infos[:klass].table_name]  = acts_as_opts
          end
        end
      end
      where_without_acts_as( opts, *rest )
    end
    # Renames the where method to where_without_acts_as, and
    # creates a where method pointing to where_with_acts_as.
    alias_method_chain :where, :acts_as
  end
  class Relation
    def scope_for_create_with_acts_as
      @scope_for_create ||= if acting_as?
        ret   = create_with_value
        acts_infos.each do |assoc, infos|
          ret   = where_values_hash.merge( where_values_hash( infos[:klass].table_name ) ).merge( ret )
        end
        ret
      else
        where_values_hash.merge( create_with_value )
      end
    end
    # Renames the scope_for_create method to scope_for_create_without_acting_as, and
    # creates a method named scope_for_create pointing to scope_for_create_with_acts_as.
    alias_method_chain :scope_for_create, :acts_as
  end
end
