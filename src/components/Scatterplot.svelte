<script>
    import AxisX from "./AxisX.svelte";
    import AxisY from "./AxisY.svelte";
    import Tooltip from "./Tooltip.svelte";
    import sociodemData from "../data/pred_individuals.json";
    import stepContent from "../data/stepContent.json";
    import politicalData from "../data/politicalClusters.json";
    import individualsData from "../data/pred_individuals.json";
    import groupData from "../data/testData_group1.json";
    import {extent} from "d3-array";
    import { fly } from "svelte/transition";
    import { scaleLinear } from "d3-scale";
    import {onMount} from "svelte";

    export let currentStep;
    export let data;
    export let currentStatus;

    let hoveredData;
    let clickedGroup;

    $: currentStepContent = stepContent[currentStep];
   
    $: width = 100;
    $: height = 800;

    $: grdata  = [];

    const margin = { top:0, right: 0, bottom: 0, left: 0 };
 
    $: innerWidth = width - margin.left - margin.right;
    $: innerHeight = height - margin.top - margin.bottom;
  
    $: xScale = scaleLinear()
      .domain([0, 100])
      .range([0, innerWidth]);
  
    $: yScale = scaleLinear()
      .domain([0, 100])
      .range([innerHeight, 0]);

    $: radiusScale = scaleLinear()
        .domain(extent(data, d => +d.NUM))
        .range([0, innerWidth/15])
  
    const loadGroupJSON = (groupID) => {
    const url = "./src/data/testData_group"+ groupID + ".json";
    return fetch(url)
      .then(response => response.json())
      .catch(error => console.error(error));
    };

    function handleCircleClick(groupID) {
      if (currentStatus == "generalViz"){
        currentStatus = "groupViz";
        console.log("click "+groupID)
        grdata = groupData.filter(d => d.groupID === groupID);
        console.log(grdata);
      }
      else{
        currentStatus = "generalViz";
        data = individualsData.map(d => ({"RIGHT_PRED": d["RIGHT.PRED"],
                                "INDEP_PRED": d["INDEP.PRED"],
                                "NUM": 1
                                      }))
      }

    }

    function getTransitionParams(d){

      let destinationX = xScale(d.RIGHT_Pred_Mean);
      let destinationY = yScale(d.INDEP_Pred_Mean);

      let originX = xScale(individualsData.filter(item => individualsData.indexOf(item) == d.Cluster)[0].RIGHT_PRED);
      let originY = yScale(individualsData.filter(item => individualsData.indexOf(item) == d.Cluster)[0].INDEP_PRED);

      const deltaX = -destinationX + originX;
      const deltaY = -destinationY + originY;

      return {
        x: deltaX,
        y: deltaY,
        duration: 1000
      };
    }

  </script>

  <div
    class="chart-container"
    bind:clientWidth={width}
    bind:clientHeight={height}>

    <svg {width} {height}
    on:mouseleave={() => hoveredData = null}>

      <g class="inner-chart" transform="translate({margin.left}, {margin.top})">
          <AxisY width={innerWidth} {yScale} {xScale}/>
          <AxisX height={innerHeight} width={innerWidth} {xScale} {yScale} />
          {#each data.sort((a, b) => a.RIGHT_PRED - b.RIGHT_PRED) as d, index}
            <!-- svelte-ignore a11y-no-noninteractive-tabindex -->
            <circle 
              transition:fly={currentStatus == "groupViz" ? { x: -100, opacity: 50, duration: 500 }
                      : {...getTransitionParams(d)}}
              cx={xScale(d.RIGHT_PRED)}
              cy={yScale(d.INDEP_PRED)}
              fill={d.NUM === 0 ? "red": "black"}
              r={d.NUM === 0 ? innerWidth/20 : radiusScale(d.NUM)}
              opacity={hoveredData ?
                        currentStatus === "politicalViz"?
                        d.RIGHT_PRED === hoveredData.RIGHT_Pred_Mean ? 1 : 0.45
                        : 0.6 : 0.6}
              on:mouseover={() => currentStatus === "sociodemViz"? hoveredData = sociodemData.find(sd => sd["INDEP.PRED"] === d.INDEP_PRED)
                            : hoveredData = politicalData.find(pd => pd.INDEP_Pred_Mean === d.INDEP_PRED)}
              on:focus={() => currentStatus === "sociodemViz"? hoveredData = sociodemData[index]
                            : hoveredData = politicalData[index]}
              on:click={() => handleCircleClick(individualsData.indexOf(d))}
              on:keydown={(event) => {
                if (event.key === 'Enter') {
                  handleCircleClick(individualsData.indexOf(d));
                }
              }}
              tabindex="0"
            />
          {/each}
        {#if currentStatus === "groupViz"}
          {#each grdata as d, index}
            <!-- svelte-ignore a11y-no-noninteractive-tabindex -->
            <circle 
              in:fly={{...getTransitionParams(d)}}
              cx={xScale(d.rightness)}
              cy={yScale(d.independence)}
              fill="black"
              stroke="none"
              r = 5
              opacity = 1
            />
          {/each}
        {/if}
      </g>
    </svg>
    {#if hoveredData}
      <Tooltip {xScale} {yScale} {width} {height} data={hoveredData} {currentStatus} />
    {/if}
  </div>
  
  <style>
  

   .chart-container{
   position: inherit;
    display: flex;
    flex-wrap: wrap;
    white-space: nowrap;
    width: 100%;
    height: 100%;
    z-index: 100;
    background: none;
    pointer-events: none;
   }
    circle {
      /*transition: r 300ms ease, opacity 500ms ease;*/
      cursor: pointer;
      pointer-events: all;
    }
    button{
      z-index: 9999;
      position: fixed;
    }
  </style>
  