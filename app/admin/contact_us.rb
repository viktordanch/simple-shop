ActiveAdmin.register ContactUs do
  permit_params :email, :topic, :message
end
