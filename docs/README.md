# Noriyo Akita's Today I Learned
This is website from [https://github.com/noriyotcp/til](noriyotcp/til)

{% for page in site.pages %}
  {% if page.path contains '.md' and page.path != 'README.md'%}
  ## [{{ page.title | default: page.basename }}]({{ page.url | relative_url }})
  ```
  {{ page.content | strip_html | truncate: 100 }}
  ```

---

  {% elsif page.url == '/docs/'%}
    <!-- Debugging Information -->
    Path: {{ page.path }}
    Title: {{ page.title | default: page.basename }}
    URL: {{ page.url | relative_url }}
  {% endif %}
{% endfor %}

