#!/bin/sh

# デフォルトの月を空に設定
month=""

# オプション解析
while [ "$1" != "" ]; do
    case $1 in
        --month )
            shift
            month=$1
            ;;
        -h | --help )
            echo "Usage: $0 --month 'YYYY-MM'"
            exit
            ;;
        * )
            echo "Invalid option: $1"
            echo "Usage: $0 --month 'YYYY-MM'"
            exit 1
    esac
    shift
done

# 月が指定されていない場合のエラーメッセージ
if [ -z "$month" ]; then
    echo "Error: --month parameter is required."
    echo "Usage: $0 --month 'YYYY-MM'"
    exit 1
fi

# 年と月を分割
year=$(echo "$month" | cut -d '-' -f 1)
month_only=$(echo "$month" | cut -d '-' -f 2)

# テンプレートの生成
cat <<EOL
---
title: "Posts in $month"
permalink: "/$year/$month_only"
layout: archive
author_profile: false
---

{% assign postsInYear = site.posts | where_exp: "item", "item.hidden != true" | group_by_exp: 'post', 'post.date | date: "%Y-%m"' %}
{% assign postsIn$year$month_only = postsInYear | where: 'name', '$month' %}

{% assign entries_layout = page.entries_layout | default: 'list' %}
{% for year in postsIn$year$month_only %}
  <section id="{{ year.name }}" class="taxonomy__section">
    <h2 class="archive__subtitle">{{ year.name }}</h2>
    <div class="entries-{{ entries_layout }}">
      {% for post in year.items %}
        {% include archive-single.html type=entries_layout %}
      {% endfor %}
    </div>
    <a href="#page-title" class="back-to-top">{{ site.data.ui-text[site.locale].back_to_top | default: 'Back to Top' }} &uarr;</a>
  </section>
{% endfor %}
EOL
