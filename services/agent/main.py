import os
import re
import json
import requests
import asyncio
import pika
from langchain_tavily import TavilySearch
from langgraph.graph import END, StateGraph
from typing import TypedDict
from dotenv import load_dotenv
from langchain.tools import Tool
from langchain_community.utilities import SearchApiAPIWrapper
from langchain_google_genai import ChatGoogleGenerativeAI

load_dotenv()
amqp_url = os.getenv("CLOUDAMQP_URL")
llm = ChatGoogleGenerativeAI(model="gemini-2.5-pro")

class GraphState(TypedDict):
    query: str
    plant_name: str
    tavily_results: list
    searchapi_results: str
    json_payload: dict

params = pika.URLParameters(amqp_url)

connection = pika.BlockingConnection(params)
channel = connection.channel()
channel.queue_declare(queue='create_new_plant')

def callback(ch, method, properties, body):
    message = body.decode()
    print("Received:", message)
    GraphState['plant_name'] = message

    result = final_graph.invoke(initial_state)
    print("Response:", result)
    ch.basic_ack(delivery_tag=method.delivery_tag)


search = SearchApiAPIWrapper()
tools = [
    Tool(
        name="intermediate_answer",
        func=search.run,
        description="useful for when you need to ask with search",
    )
]

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

def searchapi_search(state):
    url = os.getenv("SEARCHAPI_BASE_URL")
    params = {
        "engine": "google",
        "q": state["query"],
        "api_key": os.getenv("SEARCHAPI_API_KEY"),
    }
    response = requests.get(url, params=params)
    result_json = response.json()

    # Extract relevant text snippets:
    organic_results = result_json.get("organic_results", [])
    snippets = []
    for res in organic_results:
        snippet_text = res.get("snippet")
        if snippet_text:
            snippets.append(snippet_text)

    # Or knowledge graph data:
    knowledge_graph = result_json.get("knowledge_graph")
    if knowledge_graph:
        snippets.append(json.dumps(knowledge_graph))

    results = "\n\n".join(snippets)

    state["searchapi_results"] = results
    return state

def build_extraction_prompt(state):
    combined_data = f"{state["tavily_results"]}\n\n{state["searchapi_results"]}"
    prompt = f"""
    You are an expert botanist.
    From the following text, extract these attributes of the plant: "{state['query']}"
    Respond ONLY in this JSON format [the attributes are self-explanatory, with hints/range of values given adjacent to each parameter]:
    {{
    "plant_name": "...",                                            // name of the plant (string)
    "description": "...",                                           // short and concise description of the plant (string)
    "pests": ["..."],                                               // an array of pest names as (strings)
    "diseases": ["..."],                                            // an array of disease names as (strings)
    "fertilizers": ["..."],                                         // an array of fertilizer names as (strings)
    "pesticides": ["..."],                                          // an array of pesticide names as (strings)
    "instructions": "...",                                          // short description of taking care of the plant using the watering requirements data, sunlight hrs and so on (string)
    "seed_buying_links": ["...", "...", ..],                        // an array of seed buying links as (strings)
    "fertilizer_buying_links": ["...", "...", ..],                  // an array of fertilizer buying links as (strings)
    "pesticide_buying_links": ["...", "...", ..],                   // an array of pesticide buying links as (strings)
    "commonly_found": ["...","...","...", ..],                      // an array of locations where the plant is commonly found as (strings)
    "common_names": [],                                             // an array of common names of the plant as (strings)
    "appearance": {{
        "trunk_height": "...",          // 300 - 400 (string)
        "trunk_width": "...",           // 70 - 150 (string)
        "no_of_splits": "...",          // 10 - 15 (string)
        "splits_direction": "...",      // bendup/benddown (string) [whether the plant bends up or down]
        "split_lengths": "...",         // 150 - 300 (string)
        "split_bending_angle": "...",   // 0 - 90 (string)
        "no_of_branches": "...",        // 5 - 10 (string)
        "branch_lengths": "...",        // 0 - 300 (string)
        "taper": "...",                 // 0 - 100 (%) (string)
        "stem_color": "#..",            // hex color code (string)
        "branch_color": "#.."           // hex color code (string)
        "leaf_color": "#.."             // hex color code (string)
        "vein_color": "#.."             // hex color code (string)
        "margin_color": "#.."           // hex color code (string) [the color of the leaf margin]
        "leaf_width": "...",            // 0 - 100
        "leaf_height": "...",           // 0 - 100
        "leaf_spacing": "...",          // 5 - 15
        "margin": "...",                // 0 - 10
        "vein": "...",                  // 0 - 10
    }},
    "survival_requirements": {{
        "sunlight_hours": "...",        // int (string)
        "watering_capacity": "...",     // int (litres, how much water to give each time?) (string)
        "watering_frequency": "...",    // int (how many times to give water in a week?) (string)
    }}
    }}

    Don't leave any parameter blank, give only one value to each param as given in the hint, if there is no data available,
    try to give it the most appropriate value, respond ONLY in this JSON format.

    Here is the information to analyze, if in case you need more context kindly search about it:
    {combined_data}
    """
    print(f"Combined data:\n{combined_data}")
    return prompt


def extract_plant_data(state):
    prompt = build_extraction_prompt(state)
    response = llm.invoke(prompt)
    extracted_json = response.content
    try:
        match = re.search(r"```json\s*(\{.*?\})\s*```", extracted_json, re.DOTALL)
        local_json = json.loads(match.group(1))
        data = json.dumps(local_json)
    except:
        # Handle error (e.g. store raw text instead)
        data = {"error": "LLM returned invalid JSON", "raw_response": extracted_json}

    state["json_payload"] = data
    print(data)
    return state

graph = StateGraph(GraphState)

graph.add_node("search", search_node)
graph.add_node("searchapi_search", searchapi_search)
graph.add_node("extract_plant_data", extract_plant_data)

graph.set_entry_point("search")
graph.add_edge("search", "searchapi_search")
graph.add_edge("searchapi_search", "extract_plant_data")
graph.add_edge("extract_plant_data", END)

final_graph = graph.compile()

initial_state = {
    "query": f"For the plant {plant_name}, find its common names, locations, pests/diseases, best fertilizers/pesticides, planting & care tips, seed/fertilizer/pesticide links (Amazon), and appearance details: trunk/branch height, width, splits, angles, stem/leaf color, leaf shape, margin, vein, spacing, taper, alternate or not.",
    }


channel.basic_consume(queue='create_new_plant', on_message_callback=callback)
print("Waiting for messages...")
channel.start_consuming()