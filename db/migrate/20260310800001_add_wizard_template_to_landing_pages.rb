class AddWizardTemplateToLandingPages < ActiveRecord::Migration[7.0]
  def change
    add_column :landing_pages, :wizard_template, :string
  end
end
