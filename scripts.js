(() => {

	window.addEventListener('DOMContentLoaded', () => {

		let pendingFetch = {};
		let monitors     = {};

		async function refreshAddOn(key) {

			if (pendingFetch[key] === true) { return; }

			const button    = document.querySelector('button[data-refresh="' + key + '"]');
			const container = button.closest('.panel').querySelector('.content');

			pendingFetch[key] = true;
			button.disabled   = true;

			const response = await fetch('addon.cfm?fetch=' + encodeURIComponent(key));
			container.innerHTML = await response.text();

			button.disabled   = false;
			pendingFetch[key] = false;
		};

		// refresh
		document.querySelectorAll('button[data-refresh]').forEach((button) => {

			const container = button.closest('.panel').querySelector('.content');

			button.addEventListener('click', async (event) => {

				button.disabled = true;

				const addOn = event.target.getAttribute('data-refresh');

				const response = await fetch('addon.cfm?fetch=' + encodeURIComponent(addOn));
				container.innerHTML = await response.text();

				button.disabled = false;
			});
		});

		// interval
		document.querySelectorAll('button[data-interval]').forEach((button) => {

			button.addEventListener('click', async (event) => {

				const addOn    = event.target.getAttribute('data-interval');
				const isActive = (monitors[addOn] !== undefined);

				let time;
				if (!isActive) {

					time = prompt('Enter the interval (in seconds) between each automatic refresh.', '5');
					time = parseInt(time, 10);
				}

				if ((typeof time === 'number') && !isNaN(time)) {

					monitors[addOn] = setInterval(() => {

						refreshAddOn(addOn);

					}, (time * 1000));

					button.classList.add('active');

				} else {

					clearInterval(monitors[addOn]);
					delete monitors[addOn];

					button.classList.remove('active');
				}
			});
		});

		// open in new window
		document.querySelectorAll('button[data-href]').forEach((button) => {

			button.addEventListener('click', () => {

				const href   = button.getAttribute('data-href');
				const target = button.getAttribute('data-target');

				if (target === null) {

					location.href = href;

				} else {

					window.open(href, target);
				}
			});
		});

	});

})();
