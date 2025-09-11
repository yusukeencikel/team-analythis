module ApplicationHelper
  # 日付を "YYYY年M月D日 (曜)" の形式に変換する
  def format_date_with_day(date)
    return '' if date.nil?
    
    # 曜日の日本語マッピング
    wdays = {
      'Sun' => '日', 'Mon' => '月', 'Tue' => '火', 'Wed' => '水', 
      'Thu' => '木', 'Fri' => '金', 'Sat' => '土'
    }
    
    # %-m と %-d で、月と日の前の0を削除する
    formatted_date = date.strftime("%Y年%-m月%-d日")
    day_of_week = wdays[date.strftime("%a")]
    
    "#{formatted_date} (#{day_of_week})"
  end

  def sortable(column, title = nil)
    title ||= column.titleize
    direction = (column == params[:sort] && params[:direction] == "asc") ? "desc" : "asc"
    
    # アイコンの追加
    icon = ""
    if column == params[:sort]
      icon = (params[:direction] == "asc") ? " ▲" : " ▼"
    end

    # main_tab の値に応じて、ターゲットにする turbo_frame のIDを決定する
    frame_id = params[:main_tab] == 'pitching' ? 'analytics_pitching_content' : 'analytics_content'

    # 検索パラメータを維持し、turbo_frameをターゲットにするリンクを生成
    link_to (title + icon).html_safe, 
            params.permit(:year, :position, :qualified, :main_tab, :sub_tab).merge(sort: column, direction: direction),
            data: { turbo_frame: frame_id }
  end

  # yyyy年mm月dd日の形式に変換する
  def format_date_jp(date)
    return '' if date.nil?
    date.strftime("%Y年%m月%d日")
  end

  def has_award?(awards, title)
    return false if awards.blank?
    awards.any? { |a| a.name == title }
  end
end
