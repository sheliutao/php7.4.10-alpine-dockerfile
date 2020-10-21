#!/bin/bash

echo "开始执行修改redis扩展"

WORK_DIR="/opt/www";

LIBRARY_CONTENT="/sctx->cb.no_separation = 0;"

IMPL_CONTENT="/z_cb->no_separation = 0;"

COMMANDS_CONTENT="subscribeContext *sctx = emalloc(sizeof(subscribeContext));"
REPLACE_CONTENT="subscribeContext *sctx = ecalloc(1, sizeof(*sctx));"

sed -i "${LIBRARY_CONTENT}/d" ${WORK_DIR}/redis/cluster_library.c

sed -i "${LIBRARY_CONTENT}/d" ${WORK_DIR}/redis/library.c

sed -i "${IMPL_CONTENT}/d" ${WORK_DIR}/redis/redis_array_impl.c

sed -i "s/${COMMANDS_CONTENT}/${REPLACE_CONTENT}/g" ${WORK_DIR}/redis/redis_commands.c

echo "修改redis扩展结束"
