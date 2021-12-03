# frozen_string_literal: true

require 'selenium-webdriver'
require 'test/unit'

# Testing module
class TestCase < Test::Unit::TestCase
  attr_accessor :driver

  def setup
    @driver = Selenium::WebDriver.for :safari
    @driver.navigate.to 'http://svyatoslav.biz/testlab/wt/'
  end

  def teardown
    @driver.quit
  end

  # a.	Главная страница содержит слова «menu» и «banners».
  def test_page_text
    assert @driver.page_source.include? 'menu'
    assert @driver.page_source.include? 'banners'
  end

  # b.	В нижней ячейке таблицы присутствует текст «CoolSoft by Somebody».
  def test_copyright
    assert_match(/CoolSoft by Somebody/,
                 @driver.find_elements(:xpath, '/html/body/table/tbody/tr')[-1].text)
  end

  # d.	После заполнения поля «Рост» значением «50» и вес значением «3» и от-правки формы, форма исчезает, а вместо неё
  #     появляется надпись «Слиш-ком большая масса тела».
  def test_invalid_values
    _name, height, weight, _sex, submit = form_values
    height.send_keys('50')
    weight.send_keys('3')
    sleep 1
    submit.click
    sleep 1
    assert @driver.page_source.include? 'Не указано имя'
    assert @driver.page_source.include? 'Не указан пол'
  end

  # d.	После заполнения поля «Рост» значением «50» и вес значением «3» и от-правки формы, форма исчезает, а вместо неё
  #     появляется надпись «Слиш-ком большая масса тела».
  def test_invalid_result_fixed
    name, height, weight, sex, submit = form_values
    height.send_keys('50')
    weight.send_keys('3')
    name.send_keys('Anton')
    sex.click
    sleep 1
    submit.click
    sleep 3
    assert @driver.page_source.include? 'Слишком малая масса тела'
    assert_equal [], @driver.find_elements(:xpath, '/html/body/table/tbody/tr[1]/tr')
  end

  # f.	При неверном вводе значений веса и/или роста появляются сообщения о том, что рост может быть в диапазоне
  #     «50-300 см», а вес – в диапазоне «3-500 кг».
  def test_invalid_max_height_fixed
    name, height, weight, sex, submit = form_values
    height.send_keys('301')
    weight.send_keys('3')
    name.send_keys('Anton')
    sex.click
    sleep 1
    submit.click
    sleep 3
    assert @driver.page_source.include? 'Рост должен быть в диапазоне 50-300 см'
  end

  # f.	При неверном вводе значений веса и/или роста появляются сообщения о том, что рост может быть в диапазоне
  #     «50-300 см», а вес – в диапазоне «3-500 кг».
  def test_invalid_min_height_fixed
    name, height, weight, sex, submit = form_values
    height.send_keys('49')
    weight.send_keys('70')
    name.send_keys('Anton')
    sex.click
    sleep 1
    submit.click
    sleep 3
    assert @driver.page_source.include? 'Рост должен быть в диапазоне 50-300 см'
  end

  # f.	При неверном вводе значений веса и/или роста появляются сообщения о том, что рост может быть в диапазоне
  #     «50-300 см», а вес – в диапазоне «3-500 кг».
  def test_invalid_max_weight_fixed
    name, height, weight, sex, submit = form_values
    height.send_keys('170')
    weight.send_keys('501')
    name.send_keys('Anton')
    sex.click
    sleep 1
    submit.click
    sleep 3
    assert @driver.page_source.include? 'Вес должен быть в диапазоне 3-500 кг'
  end

  # f.	При неверном вводе значений веса и/или роста появляются сообщения о том, что рост может быть в диапазоне
  #     «50-300 см», а вес – в диапазоне «3-500 кг».
  def test_invalid_min_weight_fixed
    name, height, weight, sex, submit = form_values
    height.send_keys('170')
    weight.send_keys('2')
    name.send_keys('Anton')
    sex.click
    sleep 1
    submit.click
    sleep 3
    assert @driver.page_source.include? 'Вес должен быть в диапазоне 3-500 кг'
  end

  # f.	При неверном вводе значений веса и/или роста появляются сообщения о том, что рост может быть в диапазоне
  #     «50-300 см», а вес – в диапазоне «3-500 кг».
  def test_invalid_height_weight_fixed
    name, height, weight, sex, submit = form_values
    height.send_keys('500')
    weight.send_keys('2')
    name.send_keys('Anton')
    sex.click
    sleep 1
    submit.click
    sleep 3
    assert @driver.page_source.include? 'Рост должен быть в диапазоне 50-300 см'
    assert @driver.page_source.include? 'Вес должен быть в диапазоне 3-500 кг'
  end

  # f*. Проверка на влидность и отсутствие ошибок
  def test_valid_height_weight_fixed
    name, height, weight, sex, submit = form_values
    height.send_keys('170')
    weight.send_keys('60')
    name.send_keys('Anton')
    sex.click
    sleep 1
    submit.click
    sleep 10
    assert @driver.page_source.include? 'Идеальная масса тела'
  end

  # e.	Главная ��траница приложения сразу после открытия содержит форму с тремя текстовыми полями,
  #     одной группой из двух радио-баттонов и одной кнопкой.
  def test_form
    names, heights, weights, sex, submits = all_form_values
    assert_equal 1, names.length
    assert_equal 1, heights.length
    assert_equal 1, weights.length
    assert_equal 2, sex.length
    assert_equal 1, submits.length
  end

  # c1.	По умолчанию все текстовые поля формы пусты
  def test_default_text_value
    text = @driver.find_elements(:css, 'input').filter do |x|
      x.attribute('type') == 'text'
    end
    data = text.map do |x|
      x.attribute('value')
    end
    data = data.reject(&:empty?)
    assert_equal [], data
  end

  # c2.	По умолчанию значение поля «Пол» не выбрано.
  def test_default_radio
    radio = @driver.find_elements(:css, 'input').filter do |x|
      x.attribute('type') == 'radio'
    end
    data = radio.filter do |x|
      x.attribute('checked')
    end
    assert_equal [], data
  end

  # g.	Главная страница содержит текущую дату в формате «DD.MM.YYYY».
  def test_date
    time = Time.now.utc.strftime('%d.%m.%Y')
    assert @driver.page_source.include? time
  end

  private

  def form_values(checkbox = 0)
    name = get_input_field('Имя')
    height = get_input_field('Рост')
    weight = get_input_field('Вес')
    sex = get_input_field('Пол', checkbox)
    submit = @driver.find_elements(:css, 'input').filter do |x|
      x.attribute('type') == 'submit'
    end

    [name, height, weight, sex, submit[0]]
  end

  def get_input_field(name, position = 0)
    element = @driver.find_elements(:xpath, '/html/body/table/tbody/tr').select do |x|
      x.text.include? name
    end
    element[0].find_elements(:css, 'tr').select { |x| x.text.include? name }[0].find_elements(:css, 'input')[position]
  end

  def all_form_values
    name = get_all_input_field('Им��')
    height = get_all_input_field('Рост')
    weight = get_all_input_field('Вес')
    sex = get_all_input_field('Пол')
    submit = @driver.find_elements(:css, 'input').filter do |x|
      x.attribute('type') == 'submit'
    end

    [name, height, weight, sex, submit]
  end

  def get_all_input_field(name)
    element = @driver.find_elements(:xpath, '/html/body/table/tbody/tr').select do |x|
      x.text.include? name
    end
    element[0].find_elements(:css, 'tr').select { |x| x.text.include? name }[0].find_elements(:css, 'input')
  end
end
