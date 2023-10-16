const scrollableList = document.querySelector('.autoclassify ul.suggestion-results');
if (scrollableList) {
    const links = scrollableList.querySelectorAll('a')

    links.forEach(link => {
        link.addEventListener('click', function(e) {
            e.preventDefault();

            const scrollPosition = scrollableList.scrollTop;
            const href = this.getAttribute('href');

            sessionStorage.setItem('scrollPosition', scrollPosition);
            sessionStorage.setItem('targetUrl', href);

            window.location.href = href;
        })
    });

    const savedScrollPosition = sessionStorage.getItem('scrollPosition');
    const targetUrl = sessionStorage.getItem('targetUrl');

    if (savedScrollPosition && targetUrl === window.location.href) {
        scrollableList.scrollTop = savedScrollPosition;
        sessionStorage.removeItem('scrollPosition');
        sessionStorage.removeItem('targetUrl');
    }
}