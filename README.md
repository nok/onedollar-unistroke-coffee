# OneDollar.js

Implementation of the [$1 Gesture Recognizer](http://depts.washington.edu/aimgroup/proj/dollar/), a two-dimensional template based gesture recognition, for JavaScript and [jQuery](http://jquery.com/).


## About

The [$1 Gesture Recognizer](http://depts.washington.edu/aimgroup/proj/dollar/) is a research project by Wobbrock, Wilson and Li of the University of Washington and Microsoft Research. It describes a simple algorithm for accurate and fast recognition of drawn gestures.

Gestures can be recognised at any position, scale, and under any rotation. The system requires little training, achieving a 97% recognition rate with only one template for each gesture.

> Wobbrock, J.O., Wilson, A.D. and Li, Y. (2007). [Gestures without libraries, toolkits or training: A $1 recognizer for user interface prototypes](http://faculty.washington.edu/wobbrock/pubs/uist-07.1.pdf). Proceedings of the ACM Symposium on User Interface Software and Technology (UIST '07). Newport, Rhode Island (October 7-10, 2007). New York: ACM Press, pp. 159-168.

## Download

[Download via GitHub](https://github.com/voidplus/onedollar-coffeescript/archive/master.zip) or use [Bower](https://github.com/twitter/bower):

```
bower install onedollar
```

## Usage

### Plain-JavaScript

```html
<script src="onedollar.js"></script>	
```

```javascript
var one = new OneDollar();
// OR
var one = new OneDollar(80);	// optional min score of detection in percent, default: 80

one.add('triangle', [[137,139], [135,141], [154,160], [148,155] /* , ... */ ]);
one.add('circle', [[127,141] ,[124,140], [129,136], [126,139] /* , ... */ ]);
// one.remove('circle');

one.on('triangle circle', function(result){
	alert(result.name+' ('+result.score+'%)');
});
// one.off('circle');


one.check([[99,231],[108,232], ... ,[153,232],[160,233]]);
// OR
one.start(0, [99,231]); 		// start(index:int, point:Array)
one.update(0, [108,232]); 
// …
one.update(0, [153,232]);
one.end(0, [160,233]);
```

### jQuery

The plugin uses either [multitouch](http://caniuse.com/#feat=touch) or basic single mouse events.

```html
<script src="jquery.min.js"></script>
<script src="onedollar.js"></script>
<script src="jquery.onedollar.js"></script>
```

```javascript
$('#js-sketch').onedollar({
	templates: [
		['circle', [[127,141] ,[124,140], [129,136], [126,139] /* , ... */ ]],
		['triangle', [[137,139], [135,141], [154,160], [148,155] /* , ... */ ]]
	],
	binds: [
		['circle triangle', function(result){
			alert(result.name+' ('+result.score+'%)');
		}]
	]
	//, score: 80 				// optional min score of detection in percent, default: 80
});

// OR

$('#js-sketch').onedollar([
	[
		['circle', [[127,141] ,[124,140], [129,136], [126,139] /* , ... */ ]],
		['triangle', [[137,139], [135,141], [154,160], [148,155] /* , ... */ ]]
	],
	[
		['circle triangle', function(result){
			alert(result.name+' ('+result.score+'%)');
		}]
	],
	80
]);
```

### Result

```
{
	name: "triangle",			// name of template
	score: 82.89,				// percent of equality
	path: {
		start: {				// first point of the path
			x: 220,
			y: 184
		},
		end: {					// last point of the path
			x: 241,
			y: 211
		},
		centroid: {				// central point of the path
			x: 235,
			y: 269
		}
	},
	ranking: [
		{						// index 0 = best result
			name: "triangle",
			score: 82.89
		},
		{
			name: "circle",
			score: 75.84		
		}
	]
}
```

## Questions?

Don't be shy and feel free to contact me via [Twitter](https://twitter.com/darius_morawiec).

## License

The library is Open Source Software released under the [MIT License](https://raw.github.com/voidplus/onedollar-coffeescript/master/MIT-LICENSE.txt). It's developed by [Darius Morawiec](http://voidplus.de).