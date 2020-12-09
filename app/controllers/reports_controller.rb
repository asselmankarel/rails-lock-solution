require 'csv'

class ReportsController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :authenticate_server

  def handle
    report = params[:report].open
    parse_report(report)
    render json: { message: 'report has been processed' }
  end

  private

  def authenticate_server
    code_name = request.headers['X-Server-CodeName']
    token = request.headers['X-Server-Token']
    server = Server.find_by(code_name: code_name)
    render json: { error: 'wrong credentials' }, status: :unauthorized unless server&.access_token == token
  end

  def parse_report(report)
    csv_options = { col_sep: ',', headers: :first_row }
    CSV.parse(report, csv_options) do |timestamp, lock_id, kind, status|
      lock = Lock.find_by_id(lock_id[1])
      if lock
        lock.update(status: status[1])
      else
        lock = Lock.create(id: lock_id[1], kind: kind[1], status: status[1])
      end
      Entry.create(lock: lock, timestamp: timestamp[1], status: status[1])
    end
  end
end
