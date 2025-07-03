import os
import re
import json
import asyncio
from langchain_tavily import TavilySearch
from langgraph.graph import END, StateGraph
from typing import TypedDict
# from langgraph.prebuilt import create_react_agent
from dotenv import load_dotenv
from langchain_google_genai import ChatGoogleGenerativeAI

load_dotenv()

llm = ChatGoogleGenerativeAI(model="gemini-2.5-pro")

plant_name = input("Enter the plant name: ")

class GraphState(TypedDict):
    query: str
    tavily_results: list[dict[str, any]]
    json_payload: dict[str, any]

tavily_tool = TavilySearch(
    max_results=5,
    topic="general",
    # include_answer=False,
    include_raw_content=False,
    # include_images=False,
    # include_image_descriptions=False,
    search_depth="advanced",
    # time_range="day",
    # include_domains=None,
    # exclude_domains=None
)

def search_node(state):
    results = tavily_tool.invoke({"query": state["query"]})
    state["tavily_results"] = results
    return state

def build_extraction_prompt(state):
    combined_text = state["tavily_results"]
    prompt = f"""
    You are an expert botanist.
    From the following text, extract these attributes of the plant "{state['query']}":
    - Height
    - Stem size
    - Number of branches
    - Leaf color
    - Trunk color

    Respond ONLY in this JSON format:

    {{
    "plant_name": "...",
    "height": "...",
    "stem_size": "...",
    "num_branches": "...",
    "leaf_color": "...",
    "trunk_color": "..."
    }}

    Here is the information to analyze:
    {combined_text}
    """
    return prompt


def extract_plant_data(state):
    prompt = build_extraction_prompt(state)
    response = llm.invoke(prompt)
    extracted_json = response.content
    try:
        match = re.search(r"```json\s*(\{.*?\})\s*```", extracted_json, re.DOTALL)
        data = json.loads(match.group(1))
    except:
        # Handle error (e.g. store raw text instead)
        data = {"error": "LLM returned invalid JSON", "raw_response": extracted_json}

    state["json_payload"] = data
    print(data)
    return state

graph = StateGraph(GraphState)

graph.add_node("search", search_node)
graph.add_node("extract_plant_data", extract_plant_data)

graph.set_entry_point("search")
graph.add_edge("search", "extract_plant_data")
graph.add_edge("extract_plant_data", END)

final_graph = graph.compile()

initial_state = {
    "query": f"""
    what is the height (feet), stem size (cm), number of branches, leaf color (hex code), and trunk color (hex color) of the plant: {plant_name}?"""
    }
final_graph.invoke(initial_state)
