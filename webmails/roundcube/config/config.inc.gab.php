<?php

// 全员共享通讯录（johndoh/globaladdressbook 2.1）
// 数据存在 Roundcube 数据库里；管理员维护，其他人只读
// 管理员邮箱由 mailu.env 的 ROUNDCUBE_GAB_ADMINS 注入（逗号分隔），
// 由 start.py 启动时渲染到插件目录，改 env 后重建容器即可，无需重新构建镜像
$config['globaladdressbooks']['global'] = array(
    'name' => '全员通讯录',                    // 通讯录页里显示的名字
    'user' => 'global_addressbook@%d',        // 虚拟用户，%d = 按邮件域各建一本
    'perms' => 0,                             // 0 = 全员只读，仅 admin 可写
    'force_copy' => true,                     // 拖联系人到个人通讯录时用复制而非移动
    'groups' => true,                         // 允许建分组（可按部门建）
    'admin' => array({{ GAB_ADMINS }}),
    'autocomplete' => true,                   // 写邮件时收件人自动补全
    'check_safe' => true,                     // 同事来信默认显示内嵌图片
    'visibility' => null,                     // null = 所有人可见
);
