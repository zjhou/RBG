# RBG
RBG(Raw BloG) - 生成没有样式的静态博客。


### CONFIG
```
global_var() {
    site_url=$HOME/site/rbg
    home_url="/rbg"
    post_per_pg=4
    blog_title="Z+"
    blog_subtitle=""
    #optional theme: "line"
    blog_theme="line"
}
```

### USAGE
```
doc() {
cat << EOF
    
    USAGE: $0 [-d <post_title> | -p <file_name> | -l | -r | -h ]

        1. -d 删除博文，参数是博文标题
        2. -p 发布博文，参数是文件的标题，留空，则从标准输入读取。
              博文格式：第一行为标题；其余行为正文。
        3. -l 列出博文目录。
        4. -r 重新渲染网页文件。
        5. -h 显示本帮助内容。

    EXAMPLE: 

        ./rbg.sh -p example.txt
        ./rbg.sh -d test
        ./rgb.sh -l

EOF
}
```
