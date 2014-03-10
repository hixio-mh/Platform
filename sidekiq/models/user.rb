module AdefyPlatform

  User = Database.create_collection("User")

end

__END__
  class User

    include MongoMapper::Document

    key :username, String
    key email: String
    key password: String
    key apikey: String

    key :forgotPasswordToken,     String
    key :forgotPasswordTimestamp, Date

    key :fname, String, default: ""
    key :lname, String, default: ""

    key :address,    String, default: ""
    key :city,       String, default: ""
    key :state,      String, default: ""
    key :postalCode, String, default: ""
    key :country,    String, default: ""

    key :company, String, default: ""
    key :phone,   String, default: ""
    key :vat,     String, default: ""

    # 0 - admin (root)
    # 1 - unassigned
    # 2 - unassigned
    # ...
    # 7 - normal user
    key :permissions, Numeric, default: 7

    key :adFunds, Numeric, default: 0
    key :pubFunds, Numeric, default: 0

    key :transactions, [{ action: String, amount: Numeric, time: Numeric }]

    key pendingWithdrawals: [
      id: String
      source: String
      amount: Numeric
      time: Numeric
      email: String
    ]

    # Used to store intermediate transaction information. String is of the
    # format id|token
    pendingDeposit: { key: String, default: "" }

    version: { key: Numeric, default: 2 }

    key :tutorials,
      dashboard: { key: Boolean, default: true }
      apps: { key: Boolean, default: true }
      ads: { key: Boolean, default: true }
      campaigns: { key: Boolean, default: true }
      reports: { key: Boolean, default: true }
      funds: { key: Boolean, default: true }
      appDetails: { key: Boolean, default: true }
      adDetails: { key: Boolean, default: true }
      campaignDetails: { key: Boolean, default: true }

  end

end