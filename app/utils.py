import os
import logging
import markdown
import yaml

logger = logging.getLogger(__name__)

file_cache = {}


def read_file(filename):
    logger.debug(f"Reading file: {filename}")
    try:
        current_mtime = os.path.getmtime(filename)
        if filename not in file_cache or current_mtime != file_cache[filename]["mtime"]:
            with open(filename, "rb") as f:
                content = f.read()
            file_cache[filename] = {"content": content, "mtime": current_mtime}
            logger.debug(f"File {filename} read and cached")
        else:
            logger.debug(f"File {filename} served from cache")
        return file_cache[filename]["content"]
    except FileNotFoundError:
        logger.error(f"File not found: {filename}")
        raise
    except Exception as e:
        logger.error(f"Error reading file {filename}: {str(e)}")
        raise


def parse_markdown_file(file_path):
    with open(file_path, "r", encoding="utf-8") as file:
        content = file.read()
        _, frontmatter, markdown_content = content.split("---", 2)
        metadata = yaml.safe_load(frontmatter)
        html_content = markdown.markdown(markdown_content, extensions=["fenced_code"])
        return {**metadata, "content": html_content}


def generate_blog_html(posts):
    html = ""
    for post in posts:
        html += f"""
        <article>
            <h2><a hx-get="/blog/{post['slug']}" hx-target="#main-content">{post['title']}</a></h2>
            <p class="post-date">{post['date']}</p>
            <p>{post.get('excerpt', '')}</p>
        </article>
        """
    return html
