
class window.CanvasChart

    constructor: (id)->
        @margin =
            top: 20
            right: 50
            bottom: 40
            left: 50
        parent = document.getElementById(id).parentElement
        w = parent.clientWidth
        h = parent.clientHeight
        @width = w - 10 - @margin.left - @margin.right
        @height = h - 25 - 10 - @margin.top - @margin.bottom

        @svg = d3.select('#'+id).append('svg')
            .attr('class', 'chart')
            .attr('width', @width + @margin.left + @margin.right)
            .attr('height', @height + @margin.top + @margin.bottom)
            .append("g")
                .attr("transform", "translate(" + @margin.left + "," + @margin.top + ")")

        @y = d3.scale.linear()
            .range([0, @height])
            .domain([15, -15])

        @x = d3.scale.linear()
            .range([0, @width])
            .domain([-59, 0])

        @yAxis = d3.svg.axis()
            .scale(@y)
            .orient("left")

        @xAxis = d3.svg.axis()
            .scale(@x)

        x = @x
        y = @y
        @line = d3.svg.line()
            .x( (d) -> x(d.t) )
            .y( (d) -> y(d.v) )

        h = @height
        w = @width
        @svg.selectAll("path.xgrid").data(@x.ticks()).enter()
            .append("path")
              .attr('class', 'xgrid')
              .attr("d", (d) -> "M" + x(d) + " 0L" + x(d) + " " + h )

        @svg.selectAll("path.ygrid").data(@y.ticks()).enter()
            .append("path")
              .attr('class', 'ygrid')
              .attr("d", (d) -> "M0 " + y(d) + "L" + w + " " + y(d) )

        @svg.append("g")
            .attr("class", "x axis")
            .attr("transform", "translate(0," + @height + ")")
            .call(@xAxis)
             .append("text")
                .attr("x", @width/2.0)
                .attr("dy", "3em")
                .style("text-anchor", "middle")
                .text("[seconds]")

        @svg.append("g")
            .attr("class", "y axis")
            .call(@yAxis)
              .append("text")
                .attr("transform", "rotate(-90)")
                .attr("y", 6)
                .attr("dy", ".71em")
                .style("text-anchor", "end")
                .text("[m/s^2]")

        @path = @svg.append("path")
        @needle = @svg.append("path").data([10])
            .attr('class', 'needle')
            .attr('d', (d) ->
                r =  'M' + x(0) + ' ' + (y(d))
                r += 'L' + (x(0)+6) + ' ' + (y(d)+6)
                r += 'L' + (x(0)+25) + ' ' + (y(d)+6)
                r += 'L' + (x(0)+25) + ' ' + (y(d)-6)
                r += 'L' + (x(0)+6) + ' ' + (y(d)-6)
                r += 'L' + x(0) + ' ' + (y(d))
                r
            )
        @needlenum = @svg.append('text').data([10])
            .attr('class', 'needlenum')
            .style("text-anchor", "end")
            .attr('x', (d) -> x(0) )
            .attr('y', (d) -> y(d) )
            .attr('dx', '21px')
            .attr('dy', '4px')
            .text((d) -> d)

    update: (data, now)->

        timedata = []
        for d in data
            a =
                v: d.v
                t: d.t - now
            if a.t > -59
                timedata.push a

        #console.log timedata
        @path.datum(timedata)
            .attr("class", "line")
            .attr("d", @line)

        