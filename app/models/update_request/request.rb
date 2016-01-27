class UpdateRequest::Request < ActiveRecord::Base
  belongs_to :updateable, polymorphic: true
  belongs_to :requester, polymorphic: true
  belongs_to :approver, polymorphic: true

  has_many :updated_files

  scope :outstanding, -> { where(applied: false) }

  before_save :extract_files_from_schema

  after_save :reinsert_files_into_schema
  after_initialize :reinsert_files_into_schema

  serialize :update_schema

  def apply!(approver = nil)
    applied = apply(approver)
    raise ActiveRecord::RecordInvalid.new(updateable) unless applied
    applied
  end

  def apply(approver = nil)
    applied = updateable.update_attributes(
        reinclude_modules_in_attachments(update_schema)
    )

    if applied
      update_attributes(
          applied: true,
          approver: approver
      )
    end

    applied
  end

  private

  # Because the methods included in Paperclip::Attachment from the
  # Paperclip::Storage::Filesystem module are somehow lost in assigning the update
  # schema to the ActiveRecord::Base instance attribute, we need to re-include them
  def reinclude_modules_in_attachments(update_schema)
    update_schema.reduce({}) do |memo, key_and_value|
      key, value = key_and_value

      case value
        when Paperclip::Attachment
          memo[key] = value.extend(Paperclip::Storage::Filesystem)
        when Hash
          memo[key] = reinclude_modules_in_attachments(value)
        when Array
          memo[key] = value.map do |value_item|
            if value_item.kind_of?(Hash) || value_item.kind_of?(Array)
              reinclude_modules_in_attachments(value_item)
            else
              value_item
            end
          end
        else
          memo[key] = value
      end

      memo
    end

  end

  def extract_files_from_schema
    self.update_schema = extract_files_from(update_schema)
  end

  def extract_files_from(schema, prefix = '')
    schema.inject({}) do |memo, key_and_value|
      key, value = key_and_value

      if value.respond_to?(:tempfile)
        updated_files.build(attachment: value, attribute_reference: stringify_reference(prefix, key))
      else
        memo[key] =
            case value

              when Hash
                extract_files_from(value, stringify_reference(prefix, key))

              when Array

                value.each_with_index.map do |value_item, index|
                  reference = stringify_reference(stringify_reference(prefix, key), index)

                  if value_item.kind_of?(Hash) || value_item.kind_of?(Array)
                    extract_files_from(value_item, reference)
                  else
                    value_item
                  end

                end

              else
                value
            end
      end

      memo
    end
  end

  def stringify_reference(prefix, key)
    "#{prefix}[#{key.to_s}]"
  end

  def reinsert_files_into_schema
    updated_files.each do |updated_file|
      reference_string = updated_file.attribute_reference

      unless reference_string.match(/^[[:alnum:]_\[\]]+$/)
        raise ArgumentError.new("Invalid reference_string format '#{reference_string}'")
      end

      reference_chain = reference_string.scan(/[^\[^\]]+/)

      self.update_schema = insert_at_reference_chain_end(self.update_schema, reference_chain, updated_file.attachment)
    end


  end

  def insert_at_reference_chain_end(schema, reference_chain, payload)
    return schema if schema.nil?

    next_step = reference_chain.shift

    unless next_step.to_i == 0 && next_step != "0"
      next_step = next_step.to_i
    end

    if reference_chain.length > 0
      sub_schema = schema[next_step]

      if sub_schema
        sub_schema_with_payload =
            insert_at_reference_chain_end(sub_schema, reference_chain, payload)

        schema.dup.tap{|schema_clone| schema_clone[next_step] = sub_schema_with_payload }
      else
        raise ArgumentError.new(
            "File reference '#{reference_chain}' points to attribute not present in update schema '#{schema}'"
        )

      end

    else
      schema.dup.tap{|schema_clone| schema_clone[next_step] = payload }
    end
  end

end
