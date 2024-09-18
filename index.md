# Noriyo Akita's Today I Learned
This is website from [https://github.com/noriyotcp/til](noriyotcp/til)

{% assign pages = site.pages | sort: 'date' | reverse %}
{% for page in pages %}
  {% if page.path contains 'docs/' %}
  ## [{{ page.title | default: page.basename }}]({{ page.url | relative_url }})
  ```
  {{ page.content | strip_html | truncate: 100 }}
  ```
  *<small>Date: {{ page.date }} / Last modified: {{ page.last_modified_at }}</small>*

---

  {% elsif page.url == '/docs/'%}
    <!-- Debugging Information -->
    Path: {{ page.path }}
    Title: {{ page.title | default: page.basename }}
    URL: {{ page.url | relative_url }}
  {% endif %}
{% endfor %}

