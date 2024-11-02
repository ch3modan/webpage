from fastapi import APIRouter, Request
from bs4 import BeautifulSoup
import asyncio
import os
import glob
from app.utils import read_file, parse_markdown_file

router = APIRouter()


@router.get("/search")
async def handle_search(request: Request, term: str, page: str = "all"):
    search_term = term.lower()
    search_results = []

    if page == "all" or page != "blog":
        html_files = {
            "pages/home.html": "/home",
            "pages/about.html": "/about",
            "pages/projects.html": "/projects",
            "pages/contact.html": "/contact",
        }

        for file, path in html_files.items():
            try:
                content = await asyncio.to_thread(read_file, file)
                content = content.decode("utf-8")
                soup = BeautifulSoup(content, "html.parser")

                elements = soup.find_all(["p", "h1", "h2", "h3", "h4", "h5", "h6"])

                for index, element in enumerate(elements):
                    if search_term in element.text.lower():
                        excerpt = element.text[:100] + "..."
                        search_results.append(
                            {
                                "file": file,
                                "path": path,
                                "excerpt": excerpt,
                                "elementIndex": index,
                                "tagName": element.name,
                            }
                        )
            except Exception as e:
                print(f"Error searching file {file}: {str(e)}")

    if page == "all" or page == "blog":
        blog_results = await search_blog_posts(search_term)
        search_results.extend(blog_results)

    return {"results": search_results, "searchTerm": search_term}


@router.get("/search-blog")
async def handle_blog_search(term: str):
    search_results = await search_blog_posts(term)
    return {"results": search_results, "searchTerm": term}


async def search_blog_posts(search_term):
    search_results = []
    blog_post_files = glob.glob("blog_posts/*.md")

    for file_path in blog_post_files:
        try:
            post = await asyncio.to_thread(parse_markdown_file, file_path)
            if (
                search_term in post["content"].lower()
                or search_term in post["title"].lower()
            ):
                excerpt = post["content"][:200] + "..."
                search_results.append(
                    {
                        "file": os.path.basename(file_path),
                        "path": f"/blog/{post['slug']}",
                        "excerpt": excerpt,
                        "title": post["title"],
                    }
                )
        except Exception as e:
            print(f"Error searching blog post {file_path}: {str(e)}")

    return search_results
