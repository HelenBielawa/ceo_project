<script>
    import AxisX from "./AxisX.svelte";
    import AxisY from "./AxisY.svelte";
    import Tooltip from "./Tooltip.svelte";
    import stepContent from "../data/stepContent.json";
    import socioClusterData from "../data/clusters_socioeconomic.json";
    import politicalClusterData from "../data/politicalClusters.json";
    import individualsData from "../data/pred_individuals_socioeconomic.json";
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
  
    const loadGroupJSON = (cluster) => {
    const url = "./src/data/testData_group"+ cluster + ".json";
    return fetch(url)
      .then(response => response.json())
      .catch(error => console.error(error));
    };

    function handleCircleClick(cluster) {
      if (currentStatus == "generalViz" || currentStatus == "sociodemViz"){
        currentStatus = "groupViz";
        console.log("click "+cluster)
        grdata = individualsData.filter(d => d.Cluster === cluster);
        console.log(grdata);
      }
      else{
        currentStatus = "generalViz";
        data = individualsData.map(d => ({"RIGHT_PRED": d["RIGHT.PRED"],
                                "INDEP_PRED": d["INDEP.PRED"],
                                "NUM": 1,
                                "Cluster": d.Cluster
                                      }))
      }

    }

    function getTransitionParams(d){
      console.log("d: ", d);

      let destinationX = xScale(d.RIGHT_Pred_Mean);
      let destinationY = yScale(d.INDEP_Pred_Mean);

      let parentEl = socioClusterData.find(s => s.Cluster == d.Cluster)

      let originX = xScale(parentEl.RIGHT_Pred_Mean);
      let originY = yScale(parentEl.INDEP_Pred_Mean);

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
                          <!-- transition:fly={currentStatus == "groupViz" ? { x: -100, opacity: 50, duration: 500 }
                      : {...getTransitionParams(d)}} -->
            <circle 

              cx={xScale(d.RIGHT_PRED)}
              cy={yScale(d.INDEP_PRED)}
              fill={d.NUM === 0 ? "red": "black"}
              r={d.NUM === 0 ? innerWidth/20 : radiusScale(d.NUM)}
              opacity={hoveredData ?
                        currentStatus === "politicalViz"?
                        d.RIGHT_PRED === hoveredData.RIGHT_Pred_Mean ? 1 : 0.45
                        : 0.6 : 0.6}
              on:mouseover={() => currentStatus === "sociodemViz"? hoveredData = socioClusterData.find(sd => sd.INDEP_Pred_Mean === d.INDEP_PRED)
                            : hoveredData = politicalClusterData.find(pd => pd.INDEP_Pred_Mean === d.INDEP_PRED)}
              on:focus={() => currentStatus === "sociodemViz"? hoveredData = socioClusterData[index]
                            : hoveredData = politicalClusterData[index]}
              on:click={() => handleCircleClick(d.Cluster)}
              on:keydown={(event) => {
                if (event.key === 'Enter') {
                  handleCircleClick(d.Cluster);
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
              r = 1
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
  