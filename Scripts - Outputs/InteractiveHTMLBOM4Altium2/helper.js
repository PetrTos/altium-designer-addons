function arc2path(cx, cy, radius, startangle, endangle) {
    var startrad = Degrees2Radians(startangle);
    var endrad = Degrees2Radians(endangle);
    var start = [cx + (radius * Math.cos(startrad)), cy + (radius * Math.sin(startrad))];
    var end = [cx + (radius * Math.cos(endrad)), cy + (radius * Math.sin(endrad))];

    if (start[0] == end[0] && start[1] == end[1]) {
        var d = ["M", cx - radius, -cy, "a", radius, radius, 0, 1, 0, 2 * radius, 0, "a", radius, radius, 0, 1, 0, -2 * radius, 0].join(" ");
        return d;
    }

    var da = startangle > endangle ? endangle - startangle + 360 : endangle - startangle;
    var largeArcFlag = da <= 180 ? "0" : "1";
    var sweepFlag = 0;
    var d = ["M", start[0].round(), -start[1].round(), "A", radius, radius, 0, largeArcFlag, sweepFlag, end[0].round(), -end[1].round()].join(" ");

    return d;
}

function arc2tracks(cx, cy, radius, startangle, endangle) {
    var da = startangle > endangle ? endangle - startangle + 360 : endangle - startangle;
    var n;
    if (da <= 90 && da >= 0) {
        n = 4;
    } else if (da <= 180 && da > 90) {
        n = 8;
    } else if (da <= 270 && da > 180) {
        n = 16;
    } else if (da <= 360 && da > 270) {
        n = 32;
    }

    var o = [cx + radius, cy];
    // var start = rotatePoint([cx, cy], o, startangle);

    var points = [];
    var step = da / n;
    for (var i = 0; i <= n; i++) {
        points.push(rotatePoint([cx, cy], o, startangle + i * step));
    }

    var tracks = [];
    var len = points.length - 1;
    /*
    if (Prim.InPolygon) {
        for (var i = 0; i < len; i++) {
            tracks.push({
                "type": "polygon",
                "svgpath": ["M", points[i + 0], points[i + 1]].join(" "),
                "layer": Prim.Layer
            })
        }
    } else

     */
    {

        for (var i = 0; i < len; i++) {
            tracks.push({
                "type": "segment",
                "start": points[i + 0],
                "end": points[i + 1],
                "layer": Prim.Layer,
                "width": width
            })
        }
    }

    return tracks;
}

function fromaltium(_data_) {
    var result = {};
    var bom = {};
    bom.B = [];
    bom.F = [];
    bom.both = [];
    bom.fields = {};
    bom.skipped = [];

    var footprints = [];

    var drawings = {};
    drawings.fabrication = {};
    drawings.fabrication.B = [];
    drawings.fabrication.F = [];

    drawings.silkscreen = {};
    drawings.silkscreen.B = [];
    drawings.silkscreen.F = [];

    var edges = [];

    var edges_bbox = {};

    var metadata = {};

    var index = 0;

    for (const key in _data_.Data) {
        console.log(_data_.Data[key]);
        var item = _data_.Data[key];
        if (item.Layer == "TopLayer")
            bom.F.push([[item.Designator, index]]);
        if (item.Layer == "BottomLayer")
            bom.B.push([[item.Designator, index]]);
        bom.both.push([[item.Designator, index]]);
        bom.fields[index] = [item.PartNumber, item.Footprint];

        var footprint = {};
        footprint.bbox = {};
        footprint.bbox.angle = 0;
        footprint.bbox.pos = [item.X, item.Y];
        footprint.bbox.relpos = [0, 0];//[-Math.round(item.Width / 2), -Math.round(item.Height / 2)];
        //footprint.bbox.size = [Math.round(item.Width), Math.round(item.Height)];
        footprint.bbox.size = [item.Width, item.Height];

        footprint.drawings = [];
        if (item.Layer == "TopLayer")
            footprint.layer = "F";
        if (item.Layer == "BottomLayer")
            footprint.layer = "B";

        footprint.pads = [];

        for (const key2 in item.Pads) {
            var itemPad = item.Pads[key2];

            var pad = {};
            pad.angle = itemPad.Angle;
            if (itemPad.Type == "th") {
                pad.drillshape = itemPad.DrillShape;
                pad.drillsize = [0.8, 0.8];
            }
            if (itemPad.Layer == "TopLayer")
                pad.layers = ["F"];
            if (itemPad.Layer == "BottomLayer")
                pad.layers = ["B"];
            if (itemPad.Layer == "MultiLayer")
                pad.layers = ["F", "B"];
            pad.offset = [0, 0];
            //pad.path2d = {};
            if (itemPad.Pin1 == "1") {
                pad.pin1 = itemPad.Pin1;
            }
            pad.pos = [itemPad.X, itemPad.Y];
            pad.shape = itemPad.Shape;
            pad.size = [itemPad.Width, itemPad.Height];
            pad.type = itemPad.Type;

            footprint.pads.push(pad);
        }

        footprint.ref = item.Designator;
        footprints.push(footprint);

        index++;
    }

    for (const key in _data_.Board) {
        console.log(_data_.Board[key]);
        var item = _data_.Board[key];

        if (item.Type == "segment") {
            var segment = {};
            segment.end = [item.X2, item.Y2];
            segment.start = [item.X1, item.Y1];
            segment.type = "segment";
            segment.width = item.Width;
        }

        if (item.Type == "arc") {
            var segment = {};
            segment.start = [item.X, item.Y];
            segment.endangle = item.Angle2;
            segment.width = item.Width;
            segment.radius = item.Radius;
            segment.startangle = item.Angle1;
            segment.type = "arc";
        }

        edges.push(segment);
    }

    for (const key in _data_.Extra) {
        console.log(_data_.Extra[key]);
        var item = _data_.Extra[key];

        if (item.Type == "segment") {
            var segment = {};
            segment.end = [item.X2, item.Y2];
            segment.start = [item.X1, item.Y1];
            segment.type = "segment";
            segment.width = item.Width;

            if (item.Layer == "TopOverlay")
                drawings.silkscreen.F.push(segment);
            if (item.Layer == "BottomOverlay")
                drawings.silkscreen.B.push(segment);
        }
        if (item.Type == "arc") {
            var segment = {};
            segment.start = [item.X, item.Y];
            segment.endangle = item.Angle2;
            segment.width = item.Width;
            segment.radius = item.Radius;
            segment.startangle = item.Angle1;
            segment.type = "arc";

            if (item.Layer == "TopOverlay")
                drawings.silkscreen.F.push(segment);
            if (item.Layer == "BottomOverlay")
                drawings.silkscreen.B.push(segment);
        }
    }

    edges_bbox.maxx = _data_.BB.X2;
    edges_bbox.maxy = _data_.BB.Y2;
    edges_bbox.minx = _data_.BB.X1;
    edges_bbox.miny = _data_.BB.Y1;

    metadata.company = _data_.Metadata.Company;
    metadata.date = _data_.Metadata.Date;
    metadata.revision = _data_.Metadata.Revision;
    metadata.title = _data_.Metadata.Title;

    result.bom = bom;
    result.footprints = footprints;
    result.drawings = drawings;
    result.edges = edges;
    result.edges_bbox = edges_bbox;
    result.metadata = metadata;

    result.ibom_version = "v2.9.0";
    result.font_data = {};

    return result;
}

var pcbdata = fromaltium(altiumbom);