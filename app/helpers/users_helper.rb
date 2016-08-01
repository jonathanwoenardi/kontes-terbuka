module UsersHelper
  # Four of the methods below are helpers for users#show_history.
  def public_header_contents
    create_data_row %w(Kontes Penghargaan), 'th'
  end

  def public_data_contents
    safe_join(@user_contests.map do |uc|
      uc = uc.contest.results.find { |u| u.user_id == uc.user_id }
      create_data_row([uc.contest, uc.award], 'td',
                      { class: 'clickable-row',
                        'data-link' => contest_path(uc.contest) },
                      { class: uc.award.downcase })
    end)
  end

  def full_header_contents
    create_data_row %w(Kontes Nilai Peringkat Penghargaan), 'th'
  end

  def full_data_contents
    safe_join(@user_contests.map do |uc|
      uc = uc.contest.results.find { |u| u.user_id == uc.user_id }
      create_data_row([uc.contest,
                       uc.total_mark.to_s + '/' + uc.contest.max_score.to_s,
                       uc.rank.to_s + '/' +
                       UserContest.where(contest: uc.contest).length.to_s,
                       uc.award], 'td',
                      { class: 'clickable-row',
                        'data-link' => contest_path(uc.contest) },
                      { class: uc.award.downcase })
    end)
  end

  # Helper to set start user in users#index.
  def index_start
    return 0 if params[:start].nil?
    params[:start].to_i
  end

  # Helper to set start user in users#index.
  def start_plus(num)
    start_num = params[:start].to_i + num
    params.merge(start: start_num).permit(:start, :disabled)
  end

  # Helper to toggle disabled users in users#index.
  def toggle_disable
    disabled = !params[:disabled].nil? && params[:disabled] == 'true'
    prms = params.merge(disabled: !disabled).permit(:start, :disabled)
    link_to 'Toggle disabled users', prms
  end
end
