module route

import log
import veb
import model { Context }
import service.fms_api.cloud_file { CloudFile }
import service.fms_api.cloud_file_join_tag { CloudFileJoinTag }
import service.fms_api.cloud_file_tag { CloudFileTag }
import service.fms_api.file { File }
import service.fms_api.file_join_tag { FileJoinTag }
import service.fms_api.file_tag { FileTag }
import service.fms_api.storage_provider { StorageProvider }

// =============================================================================
// 文件管理 路由注册
//
// 本地文件、云文件、标签、存储提供商
// 使用 register_routes_platform（管理端接口）
// 每个资源子模块使用独立 controller，保持原完整 URL 不变。
// =============================================================================

fn (mut app AliasApp) routes_fms(mut ctx Context) {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	app.register_routes_platform[CloudFile](mut &CloudFile{}, '/fms/cloudfile', mut ctx)
	app.register_routes_platform[CloudFileTag](mut &CloudFileTag{}, '/fms/cloudtag', mut ctx)
	app.register_routes_platform[CloudFileJoinTag](mut &CloudFileJoinTag{}, '/fms/cloudfile_tag',
		mut ctx)
	app.register_routes_platform[File](mut &File{}, '/fms/file', mut ctx)
	app.register_routes_platform[FileTag](mut &FileTag{}, '/fms/tag', mut ctx)
	app.register_routes_platform[FileJoinTag](mut &FileJoinTag{}, '/fms/file_tag', mut ctx)
	app.register_routes_platform[StorageProvider](mut &StorageProvider{}, '/fms/provider',
		mut ctx)
}

fn openapi_tags_fms() []veb.OpenApiTagConfig {
	return [
		veb.OpenApiTagConfig{
			name:        'fms'
			summary:     '文件服务'
			description: '文件、云文件、标签和存储提供商。'
		},
		veb.OpenApiTagConfig{
			name:        'fms.cloud_file'
			summary:     '云文件'
			description: '云文件资源维护。'
			parent:      'fms'
			controllers: [typeof(CloudFile{}).name.trim_left('&')]
		},
		veb.OpenApiTagConfig{
			name:        'fms.cloud_file_tag'
			summary:     '云文件标签'
			description: '云文件标签维护。'
			parent:      'fms'
			controllers: [typeof(CloudFileTag{}).name.trim_left('&')]
		},
		veb.OpenApiTagConfig{
			name:        'fms.cloud_file_join_tag'
			summary:     '云文件标签关联'
			description: '云文件与标签的关联关系。'
			parent:      'fms'
			controllers: [typeof(CloudFileJoinTag{}).name.trim_left('&')]
		},
		veb.OpenApiTagConfig{
			name:        'fms.file'
			summary:     '文件'
			description: '本地文件资源维护。'
			parent:      'fms'
			controllers: [typeof(File{}).name.trim_left('&')]
		},
		veb.OpenApiTagConfig{
			name:        'fms.file_tag'
			summary:     '文件标签'
			description: '本地文件标签维护。'
			parent:      'fms'
			controllers: [typeof(FileTag{}).name.trim_left('&')]
		},
		veb.OpenApiTagConfig{
			name:        'fms.file_join_tag'
			summary:     '文件标签关联'
			description: '本地文件与标签的关联关系。'
			parent:      'fms'
			controllers: [typeof(FileJoinTag{}).name.trim_left('&')]
		},
		veb.OpenApiTagConfig{
			name:        'fms.storage_provider'
			summary:     '存储提供商'
			description: '对象存储和本地存储提供商配置。'
			parent:      'fms'
			controllers: [typeof(StorageProvider{}).name.trim_left('&')]
		},
	]
}
