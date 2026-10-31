module route

import log
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
