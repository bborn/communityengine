# Ugly fix because BootstrapForm always expects an AR object.

BootstrapForm::FormBuilder.class_eval do

  def required_attribute?(obj, attribute)
    return false unless obj.respond_to?(:validators_on)
    return false unless obj and attribute

    target = (obj.class == Class) ? obj : obj.class
    target_validators = target.validators_on(attribute).map(&:class)

    has_presence_validator = target_validators.include?(
                               ActiveModel::Validations::PresenceValidator)

    if defined? ActiveRecord::Validations::PresenceValidator
      has_presence_validator |= target_validators.include?(
                                  ActiveRecord::Validations::PresenceValidator)
    end

    has_presence_validator
  end



end
