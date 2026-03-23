from crewai import Agent, Crew, Process, Task
from crewai.project import CrewBase, agent, crew, task
from crewai.agents.agent_builder.base_agent import BaseAgent
from typing import List
from crewai_tools import SerperDevTool

import os

from crewai import LLM

llm = LLM(model="amazon.nova-pro-v1:0")

serper_api_key = SerperDevTool(api_key=os.getenv('Serper_API_KEY')) ##Generate a new API KEY, this has expired
#serper_api_key = SerperDevTool(api_key="b301ba910de84cab92318edd7c0ce881dfe3f936") ##Generate a new API KEY, this has expired

@CrewBase
class AiTravelPlanner():
    """AiTravelPlanner crew"""

    agents: List[BaseAgent]
    tasks: List[Task]

    # Agent
    @agent
    def travel_researcher(self) -> Agent:
        return Agent(
            config=self.agents_config['travel_researcher'],
            verbose=True,
            tools=[serper_api_key],
            llm = llm
        )

    @agent
    def itinerary_planner(self) -> Agent:
        return Agent(
            config=self.agents_config['itinerary_planner'],
            verbose=True,
            llm = llm
        )

    # Task
    @task
    def research_task(self) -> Task:
        return Task(
            config=self.tasks_config['research_task'],
        )

    @task
    def reporting_task(self) -> Task:
        return Task(
            config=self.tasks_config['reporting_task'],
            output_file='report.md'
        )

    @crew
    def crew(self) -> Crew:
        """Creates the AiTravelPlanner crew"""

        return Crew(
            agents=self.agents,
            tasks=self.tasks,
            process=Process.sequential,
            verbose=True
        )
