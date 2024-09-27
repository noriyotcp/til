#!/bin/sh

# デフォルトの年を空に設定
year=""

# オプション解析
while [ "$1" != "" ]; do
    case $1 in
        year=* )
            year="${1#*=}"
            ;;
        -h | --help )
            echo "Usage: $0 year=YYYY"
            exit
            ;;
        * )
            echo "Invalid option: $1"
            echo "Usage: $0 year=YYYY"
            exit 1
    esac
    shift
done

# 年が指定されていない場合のエラーメッセージ
if [ -z "$year" ]; then
    echo "Error: year parameter is required."
    echo "Usage: $0 year=YYYY"
    exit 1
fi

# テンプレートの生成
cat <<EOL
---
title: "Posts in $year"
permalink: /$year/
layout: archive
author_profile: false
---

{% include back_to_posts_by_year.html %}

<ul class="taxonomy__index">
  {% assign postsByYearMonth = site.posts | where_exp: "item", "item.hidden != true" | group_by_exp: 'post', 'post.date | date: "%Y-%m"' %}
  {% assign postsIn$year = postsByYearMonth | where: 'name', '$year' %}
  {% for year in postsByYearMonth %}
    <li>
      <a href="#{{ year.name }}">
        <strong>{{ year.name }}</strong> <span class="taxonomy__count">{{ year.items | size }}</span>
      </a>
    </li>
  {% endfor %}
</ul>

{% assign entries_layout = page.entries_layout | default: 'list' %}
<!-- {% assign postsIn$year = postsInYear | where: 'name', '$year' %} -->
{% for year in postsByYearMonth %}
  <section id="{{ year.name }}" class="taxonomy__section">
    <h2 class="archive__subtitle">{{ year.name }}</h2>
    <div class="entries-{{ entries_layout }}">
      {% for post in year.items %}
        {% include archive-single.html type=entries_layout %}
      {% endfor %}
    </div>
    <div class="back-to-top-container">
      <a href="#page-title" class="back-to-top">BACK TO TOP &uarr;</a>
      <a href="#{{ year.name }}" class="back-to-top">BACK TO {{ year.name }} &uarr;</a>
    </div>
  </section>
{% endfor %}
EOL

