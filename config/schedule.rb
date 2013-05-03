Crom.schedule do
  every '5m' do
    Request.where("request_time < ?", 20.minutes.ago).delete_all
  end

  # 1 month = 60 * 24 * 365.25/12
  every '43830m' do
    User.each do |user|
      user.update_name
    end
    Admin.each do |admin|
      admin.update_name
    end
  end
end
