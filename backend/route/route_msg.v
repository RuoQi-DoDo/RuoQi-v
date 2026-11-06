module route

import log
import veb
import model { Context }
import service.msg_api.emaillog { EmailLog }
import service.msg_api.emailprovider { EmailProvider }
import service.msg_api.messagesender { MessageSender }
import service.msg_api.smslog { SmsLog }
import service.msg_api.smsprovider { SmsProvider }

// =============================================================================
// 消息中心 路由注册
//
// 电子邮件 + 短信 的 日志、提供商、发送器
// 全使用 register_routes_platform（管理端接口）
// =============================================================================

fn (mut app AliasApp) routes_msg(mut ctx Context) {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	// Email log management
	app.register_routes_platform[EmailLog](mut &EmailLog{}, '/msg/emaillog', mut ctx)

	// Email provider management
	app.register_routes_platform[EmailProvider](mut &EmailProvider{}, '/msg/emailprovider', mut ctx)

	// SMS log management
	app.register_routes_platform[SmsLog](mut &SmsLog{}, '/msg/smslog', mut ctx)

	// SMS provider management
	app.register_routes_platform[SmsProvider](mut &SmsProvider{}, '/msg/smsprovider', mut ctx)

	// Message sender (send operations)
	app.register_routes_platform[MessageSender](mut &MessageSender{}, '/msg/sender', mut ctx)
}

fn openapi_tags_msg() []veb.OpenApiTagConfig {
	return [
		veb.OpenApiTagConfig{
			name:        'msg'
			summary:     '消息中心'
			description: '邮件、短信、发送器和消息日志。'
		},
		veb.OpenApiTagConfig{
			name:        'msg.email_log'
			summary:     '邮件日志'
			description: '邮件发送记录。'
			parent:      'msg'
			controllers: [typeof(EmailLog{}).name.trim_left('&')]
		},
		veb.OpenApiTagConfig{
			name:        'msg.email_provider'
			summary:     '邮件提供商'
			description: '邮件发送渠道配置。'
			parent:      'msg'
			controllers: [typeof(EmailProvider{}).name.trim_left('&')]
		},
		veb.OpenApiTagConfig{
			name:        'msg.sms_log'
			summary:     '短信日志'
			description: '短信发送记录。'
			parent:      'msg'
			controllers: [typeof(SmsLog{}).name.trim_left('&')]
		},
		veb.OpenApiTagConfig{
			name:        'msg.sms_provider'
			summary:     '短信提供商'
			description: '短信发送渠道配置。'
			parent:      'msg'
			controllers: [typeof(SmsProvider{}).name.trim_left('&')]
		},
		veb.OpenApiTagConfig{
			name:        'msg.sender'
			summary:     '消息发送'
			description: '邮件和短信发送入口。'
			parent:      'msg'
			controllers: [typeof(MessageSender{}).name.trim_left('&')]
		},
	]
}
