class StatusHelper
  def self.invites
    return [:ready, :pending, :invite_send, :request_send, :accepted, :declined,
            :owner_accepted, :owner_declined, :active, :time_expired]
  end

  def self.accounts
    return [:pending, :approved, :denied]
  end

  def self.events
    return [:just_added, :pending, :approved, :denied, :active, :inactive]
  end

  def self.admin_translations
    return {
      just_added: "new",
      pending: "pending",
      approved: "approved",
      denied: "denied",
      active: "active",
      inactive: "inactive"
    }
  end
end