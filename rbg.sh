#!/bin/bash
#script: rbg.sh
#describe: raw blog generator
#date: 2015-11-29
#inspiration: bashblog
#copyright: null

global_var() {
    site_url=$HOME/site/rbg
    home_url="/rbg"
    post_per_pg=4
    blog_title="Z+"
    blog_subtitle=""
    #optional theme: "line"
    blog_theme="line"

}


publish() {
    {
        if [ $# -eq 0 ]; then
            cat
        else
            cat $1
        fi
    } > $site_url/___.raw

    local title=`head -n1 $site_url/___.raw`
    mv $site_url/___.raw $site_url/$title.raw

    refresh
}

#$1 dir
is_dir_empty?() {
	if [ "$(ls -A $1)" ]; then
		return 1
	else
		return 0
	fi
}

#$* 博文标题
#删除博文

del() {
    for post in $*; do
        if [ -f $site_url/$post.raw ]; then
            rm $site_url/$post.raw
        else
            echo "can't find post: $post"
            return 1
        fi
    done

    refresh

    if is_dir_empty? $site_url; then
        echo null > $site_url/index.html
    fi

    return 0
}

#Math.ceil($1/$2)
myceil() {
    if [ $(($1%$2)) -eq 0 ]; then
        echo $(($1/$2))
    else
        echo $(( (($1/$2)+1) ))
    fi
        
}


#$1 theme name
theme() { 
    case "$1" in 
        "line" )
            sed '/^<[p|m]/ ! s/\(^[0-9]*\-[0-9]*\-[0-9]*\)/                        \1 +---------/; t;
                 /^<[p|m]/ ! s/^/                                   | /';;
        "default" )
            sed '/^<[p|m]/ ! s/^/    /';;
    esac


}

#$1 post name
get_time() {
    echo `ls -l --time-style=+"%Y-%m-%d" $site_url/$1 | \
          grep -oE '[0-9]+\-[0-9]+\-[0-9]+'`
}

#$* posts name
gen_content() {
    for post in $*; do
        echo -e "\n\n"
        local time=`get_time $post`
        sed "1a $time\n" $post
    done
}

#$1 pagenum 
#$2 total_pagenum
#stdin
gen_page() {
#header
cat << EOF
<meta charset="utf-8">
<pre>



<a href='$home_url'>$blog_title</a>



$blog_subtitle
EOF

    cat

    if [ $(($1+1)) -lt $2 ]; then
        local nex_lnk="<a href='$home_url/page$(($1+1)).html'>NEXT</a>"
    elif [ $(($1+1)) -eq $2 ]; then
        local nex_lnk=""
    fi

    if [ $1 -eq 0 ]; then
        local pre_lnk=""
    elif [ $1 -eq 1 ]; then
        local pre_lnk="<a href='$home_url'>PREV</a>"
    else
        local pre_lnk="<a href='$home_url/page$(($1-1)).html'>PREV</a>"
    fi

#footer 
cat << EOF


$pre_lnk ($(($1+1))/$2) $nex_lnk
</pre>
EOF
}



generate() {
    local posts_name=(`ls -t --format=single-column $site_url/*.raw | \
                        awk -F '/' '{print $NF}'`)


    local total_posts=${#posts_name[@]}
    local total_pages=`myceil $total_posts $post_per_pg`

    for ((i=0; i<$total_pages; i++)); do
        if [ $i -eq 0 ]; then        
            gen_content ${posts_name[@]:0:$post_per_pg} | \
            gen_page $i $total_pages | \
            theme $blog_theme > $site_url/index.html
        else
            gen_content ${posts_name[@]:$(($i*$post_per_pg)):$post_per_pg} | \
            gen_page $i $total_pages | \
            theme $blog_theme > $site_url/page$i.html 
        fi
    done

}

refresh() {
    cd $site_url
    if [ -f index.html ]; then
        rm $site_url/*.html
    fi

    generate
    cd - &> /dev/null
}

list() {
    ls -t --format=single-column $site_url/*.raw | \
    awk -F '/' '{print $NF}' | sed 's/.raw//g'
}

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

main() {
    global_var

    if [ $# -eq 0 ]; then
        doc
    fi

    while getopts "p:lrd:h" Option
    do
        case $Option in 
            p) publish $OPTARG;;
            l) list;;
            r) refresh;;
            d) del $OPTARG;;
            h) doc;;
            *) doc;;
        esac
    done
}
#*************
main $* #*****
#*************
