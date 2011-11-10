# Ab Crunch
*by TrueCar*

The idea behind Ab Crunch is that basic performance metrics and standards should
be effortless, first-class citizens in the development process, with frequent visibility
and immediate feedback when performance issues are introduced.

Other tools exist for measuring performance, but we found that they had some drawbacks:

* Not easily integrated into routine development practices, such as automated testing and CI
* Take a long time to set up.
* Take a long time to use.

We wanted a tool that, while simple, was valid enough to surface basic performance
issues and fast/easy enough to use throughout all our projects.

Ab Crunch uses Apache Bench to run various strategies for load testing web sites.
It generates rake tasks for running all or some of our tests.  These can be configured
to be just informational, or to fail when specified standards are not met.  The rake
tasks can then be added to our Continuous Integration (CI) builds, so builds fail when
performance degrades.

### Credits

Christopher "Kai" Lichti, Author  
Aaron Hopkins, adviser / contributed strategies  
John Williams, adviser / contributed strategies  
TrueCar, Inc, for giving us jobs and letting us share this gem

### Prerequisites

Must have Apache Bench installed and 'ab' on your path

### Quick Start Guide

To see some immediate action, require the gem, and run 'rake abcrunch:example'

Now to use it on your own pages:

First, define the pages you want to test, and (optionally), the performance
requirements you want them to meet.  If you exclude any requirements, your
load test will be informational only, and won't log or raise any errors
based on performance standards.

For Example:

    @load_test_page_sets = {
      :production => [
        {
          :name => "Google home page",
          :url => "http://www.google.com/",
          :min_queries_per_second => 20,
          :max_avg_response_time => 1000,
        },
        {
          :name => "Facebook home page",
          :url => "http://www.facebook.com/",
        }
      ],
      :staging => [
        {
          :name => "Github home page",
          :url => "http://www.github.com/",
          :max_avg_response_time => 1000,
        }
      ]
    }
    
    require 'abcrunch'
    AbCrunch::Config.page_sets = @load_test_page_sets

In Rails, you can do this in your development and test environments.

Once you've configured Ab Crunch, you can run rake tasks to load test your pages, like this:

    rake abcrunch:staging
     - or -
    rake abcrunch:all

### Configuring Pages

* `:name`: (required) User-friendly name for the page.
* `:url`: (required) Url to test. Can be a string or a Proc. Proc example:

        :url => proc do
          "http://www.google.com/?q=#{['food','coma','weirds','code'][rand(4)]}"
        end,

**Performance requirements (will raise so CI builds break when requirements fail)**

* `:min_queries_per_second`: page must support at least this many QPS
* `:max_avg_response_time`: latency for the page cannot go higher than this

**Other Options**

* `:num_requests` - how many requests to make during each (of many) runs [Default: 50]
* `:max_latency` - global maximum latency (in ms) considered to be acceptable [Default: 1000]
* `:max_degradation_percent` - global max percent latency can degrade before being considered unacceptable [Default: 0.5 (iow 50%)]

### Examples

**Iterative Optimization**

Running a focus load test to iterate fixing a performance issue.

If a specific page is too slow, you can iterate on that page using a focus rake task, like so:

    rake abcrunch:dev:focus[3]

**Configuring the same URLS in multiple environments (dev, qa, staging, prod...)**

Here's an example showing how you might dry up the AbCrunch configuration to support multiple environments.

    def init_env
      if ['development', 'test'].include? RAILS_ENV
        require 'abcrunch'
        AbCrunch::Config.page_sets = ab_crunch_page_sets
      end
    end
    
    def ab_crunch_page_sets
      def page_with_domain(page, domain)
        new = page.clone
        new[:url] = page[:url].gsub '<domain>', domain
        new
      end
      
      result = {
        :dev => AB_CRUNCH_PAGE_SET_TEMPLATE.collect { |page| page_with_domain(page, 'http://localhost:3000') },
        :qa => AB_CRUNCH_PAGE_SET_TEMPLATE.collect { |page| page_with_domain(page, 'http://qa.myapp.com') },
        :staging => AB_CRUNCH_PAGE_SET_TEMPLATE.collect { |page| page_with_domain(page, 'http://staging.myapp.com') },
        :prod => AB_CRUNCH_PAGE_SET_TEMPLATE.collect { |page| page_with_domain(page, 'http://www.myapp.com') },
      }
      
      result
    end
    
    AB_CRUNCH_PAGE_SET_TEMPLATE = [
      {
        :name => "Home",
        :url => "<domain>/",
        :min_queries_per_second => 50,
      },
      {
        :name => "Blog",
        :url => "<domain>/blog?user=honest_auto",
        :max_avg_response_time => 450,
      }
    ]


### Known Gotcha

Apache Bench does not like urls that just end with the domain. For example:  
`http://www.google.com` is BAD, but  
`http://www.google.com/` is fine, for reasons surpassing understanding.  
...so for root level urls, be sure to add a trailing slash.

### License

The MIT License
Copyright (c) 2011 TrueCar, Inc.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.