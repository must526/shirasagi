class Gws::Discussion::Post
  include Gws::Discussion::Postable
  include Gws::Addon::Contributor
  include SS::Addon::Markdown
  include Gws::Addon::File
  #include Gws::Addon::Discussion::NotifySetting
  #include Gws::Addon::Discussion::Release
  #include Gws::Addon::Member
  include Gws::Addon::GroupPermission
  include Gws::Addon::Discussion::Quota
  include Gws::Addon::History

  set_permission_name "gws_discussion_posts"

  validates :text, presence: true

  def save_notify_message(site, user)
    f = Gws::Discussion::Forum.find(forum.id)
    return if f.deleted?
    return unless f.public?
    return unless f.notify_enabled?

    notify_member_ids = f.discussion_member_ids - [user.id]
    return if notify_member_ids.blank?

    item = Gws::Memo::Notice.new
    item.cur_site = site
    item.cur_user = user
    item.member_ids = notify_member_ids
    item.subject = I18n.t("gws/discussion.notify_message.post.subject", forum_name: forum.name, topic_name: topic.name)
    item.format = "text"
    item.text = I18n.t("gws/discussion.notify_message.post.text", topic_name: topic.name, text: text)
    item.send_date = Time.zone.now

    # set topic
    item.reply_item_id = topic.id
    item.reply_model = topic.reference_model
    item.reply_module = "discussion"
    item.save!
  end
end
