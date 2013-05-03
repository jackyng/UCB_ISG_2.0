Crom.schedule do
  every '5m' do
    Request.where("request_time < ?", 20.minutes.ago).delete_all
  end
end
